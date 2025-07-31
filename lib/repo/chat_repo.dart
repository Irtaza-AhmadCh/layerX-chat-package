import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as fPath;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart' as RxDart;
import 'package:url_launcher/url_launcher.dart';

import '../../repo/chat_repo.dart';
import '../../widgets/custom_snack_bar.dart';

import 'package:logger/logger.dart';

import '../mvvm/model/chat_meta_data_model.dart';
import '../mvvm/model/firebase_user_model.dart';
import '../mvvm/model/message_model.dart';

class ChatRepo {
  static final Logger _logger = Logger();


  static String generateChatBoxIdTwo(String userId, String recipientId, String dId) {
    List<String> sortedIds = [userId, recipientId, dId]..sort();
    return sortedIds.join('_');
  }

  static Future<void> batchWriteMessageAndMetadata({
    required String chatBoxId,
    required String messageId,
    required MessageModel messageData,
    required ChatMetadataModel metaData,
  }) async {
    try {
      final batch = FirebaseFirestore.instance.batch();

      final messageRef = FirebaseFirestore.instance
          .collection('UsersChatBox')
          .doc(chatBoxId)
          .collection('chats')
          .doc(messageId);

      final metaRef = FirebaseFirestore.instance
          .collection('UsersChatBox')
          .doc(chatBoxId);

      batch.set(messageRef, messageData.toJson());
      batch.set(metaRef, metaData.toJson());

      await batch.commit();
    } catch (e) {
      _logger.e('Failed to batch write message and metadata: $e');
      rethrow;
    }
  }

  static Stream<ChatMetadataModel> getMetaData(String chatBoxId) {
    return FirebaseFirestore.instance
        .collection('UsersChatBox')
        .doc(chatBoxId)
        .snapshots()
        .map((snap) => ChatMetadataModel.fromJson(snap.data() ?? {}));
  }

  static Future<void> writeMetaData(String chatBoxId, ChatMetadataModel metaDataModel) async {
    try {
      await FirebaseFirestore.instance
          .collection('UsersChatBox')
          .doc(chatBoxId)
          .set(metaDataModel.toJson());
    } catch (e) {
      _logger.e('Failed to write metadata: $e');
      rethrow;
    }
  }

  static Future<void> updateMetaData(Map<String, dynamic> data, String chatBoxId) async {
    try {
      await FirebaseFirestore.instance
          .collection('UsersChatBox')
          .doc(chatBoxId)
          .update(data);
    } catch (e) {
      _logger.e('Failed to update metadata: $e');
      rethrow;
    }
  }

  static Stream<List<MessageModel>> getOrderedChatsModelList(String chatBoxId) {
    return FirebaseFirestore.instance
        .collection('UsersChatBox')
        .doc(chatBoxId)
        .collection('chats')
        .orderBy('messageSendTime', descending: false) // Ensure ordering
        .snapshots()
        .map((snap) => snap.docs.map((doc) => MessageModel.fromJson(doc.data())).toList());
  }






  static Future<void> updateMessage({
    required String chatBoxId,
    required String messageId,
    required Map<String, dynamic> updatedData,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('UsersChatBox')
          .doc(chatBoxId)
          .collection('chats')
          .doc(messageId)
          .update(updatedData);
    } catch (e) {
      _logger.e('Failed to update message: $e');
      rethrow;
    }
  }

  static Future<void> addUserDataOnFirebase({required FireBaseUserModel userDataModel}) async {
    try {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userDataModel.userAppId)
          .set(userDataModel.toJson());
    } catch (e) {
      _logger.e('Failed to add user data: $e');
      rethrow;
    }
  }

  static Future<void> deleteUserAccount({required String userId}) async {
    try {
      await FirebaseFirestore.instance.collection('Users').doc(userId).delete();
    } catch (e) {
      _logger.e('Failed to delete user account: $e');
      rethrow;
    }
  }

  static FireBaseUserModel createFireBaseUserModel({
    required String userAppId,
    required String profileImage,
    required String userPhone,
    required String userName,
    required String role,
  }) =>
      FireBaseUserModel(
        userAppId: userAppId,
        userName: userName,
        userPhone: userPhone,
        profileImage: profileImage,
        status: '',
        role: role,
        fcmToken: '',
        inboxIds: [],
        userEmail: '',
      );

  static Stream<FireBaseUserModel?> getFireBaseUsersIdStream(String userId) {
    return FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .snapshots()
        .map((snap) => snap.exists ? FireBaseUserModel.fromJson(snap.data()!) : null);
  }

  static Future<FireBaseUserModel?> getFireBaseUsersIdOneTime(String userId) async {
    try {
      final snap = await FirebaseFirestore.instance.collection('Users').doc(userId).get();
      return snap.exists ? FireBaseUserModel.fromJson(snap.data()!) : null;
    } catch (e) {
      _logger.e('Failed to get user data: $e');
      return null;
    }
  }

  static Future<List<FireBaseUserModel>> getAllFireBaseUsers(String currentUserId) async {
    try {
      final snap = await FirebaseFirestore.instance.collection('Users').get();
      return snap.docs
          .map((doc) => FireBaseUserModel.fromJson(doc.data()))
          .where((u) => u.userAppId != currentUserId)
          .toList();
    } catch (e) {
      _logger.e('Failed to get all users: $e');
      return [];
    }
  }

  static Future<void> updateReadStatus(String chatBoxId, String messageId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('UsersChatBox')
          .doc(chatBoxId)
          .collection('chats')
          .doc(messageId)
          .update({'readStatus': newStatus});
    } catch (e) {
      _logger.e('Failed to update read status: $e');
      rethrow;
    }
  }

  static Stream<List<ChatMetadataModel>> getUserInbox(String userId) {
    try {
      return FirebaseFirestore.instance
          .collection('UsersChatBox')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => ChatMetadataModel.fromJson(doc.data()))
            .where((chatMeta) => chatMeta.members.any((member) => member.id == userId))
            .toList();
      })
          .debounceTime(Duration(milliseconds: 500));
    } catch (e) {
      _logger.e('Error fetching inbox: $e');
      return const Stream.empty();
    }
  }

}
