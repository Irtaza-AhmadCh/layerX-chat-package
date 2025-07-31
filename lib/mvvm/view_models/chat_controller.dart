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
import 'package:layerx_fire_chat/utils/logger_services.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as fPath;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart' as RxDart;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../repo/chat_repo.dart';
import '../../widgets/custom_snack_bar.dart';
import '../model/chat_meta_data_model.dart';
import '../model/chat_view_argument_model.dart';
import '../model/firebase_user_model.dart';
import '../model/message_model.dart';
import '../view/chat_view.dart';


class ChatController extends GetxController {
  RxBool loader = false.obs;
  Rx<MessageType> rXmessageType = MessageType.text.obs;
  RxBool isFirstMessage = true.obs;
  ScrollController messageScrollController = ScrollController();
  RxBool showScrollToBottomButton = false.obs;
  final box = GetStorage();


  RxBool forwardLoader = false.obs;

  RxBool isScrolled = false.obs;
  FireBaseUserModel? userModel;
  TextEditingController messageController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  Map<String, dynamic>? userDataMap;
  String senderId = '';
  Rx<File?> rXfile = Rx<File?>(null);
  RxList<File>? files = RxList<File>([]);
  RxList groupMembers = [].obs;
  final ImagePicker picker = ImagePicker();
  final Logger _logger = Logger(); // Updated to use packer Logger
  final List<String> videoExtensions = ['.mp4'];
  final List<String> videoExtensionsForPicker = ['mp4'];

  // Store unread counts per chatBoxId
  final RxMap<String, int> unreadMessageCountMap = <String, int>{}.obs;

  List<String> imageExtensions = [".jpg", ".jpeg", ".png"];
  List<String> documentExtensions = [".pdf", ".docx", ".xlsx"];
  List<String> imageExtensionsForPicker = ["jpg", "jpeg", "png"];
  List<String> documentExtensionsFonsForPicker = ["pdf", "docx", "xlsx"];

  final RxList<ChatMetadataModel> allChats = <ChatMetadataModel>[].obs; // All chats
  final RxList<ChatMetadataModel> filteredChats = <ChatMetadataModel>[].obs; // Searched chats
  final RxString searchQuery = ''.obs;

  StreamSubscription? _unreadSubscription;

  final RxMap<String, FireBaseUserModel?> userCache = <String, FireBaseUserModel?>{}.obs;

  final RxList<MessageModel> messages = <MessageModel>[].obs;

  final RxString selectedMessageId = ''.obs;
  final FocusNode messageFieldFocusNode = FocusNode();


  void toggleSelectedMessage(String messageId) {
    if (selectedMessageId.value == messageId) {
      selectedMessageId.value = ''; // Deselect
    } else {
      selectedMessageId.value = messageId;
    }
  }

  bool isSelected(String messageId) => selectedMessageId.value == messageId;

  final RxString editingMessageId = ''.obs;

  void startEditingMessage(MessageModel message) {
    editingMessageId.value = message.messageId;
    messageController.text = message.messageBody;
    Future.delayed(Duration(milliseconds: 100), () {
      messageFieldFocusNode.requestFocus();
    });

  }

  void cancelEditing() {
    editingMessageId.value = '';
    selectedMessageId.value = '';
    messageController.clear();
  }

  Future<void> deleteMessage(String chatBoxId) async{
    final msgId = selectedMessageId.value;
    LoggerService.i('deleteMessage id $msgId chat box id $chatBoxId'); // Updated logger method
    if (msgId.isEmpty) return;
    try {
      await ChatRepo.updateMessage(
        chatBoxId: chatBoxId,
        messageId: msgId,
        updatedData: {
          'messageType': MessageType.deleted.name,
          'messageBody': 'This message had been deleted'
        },
      );
      cancelEditing(); // Clear after update
    } catch (e) {
      _logger.e('Error updating message: $e'); // Updated logger method
      // Optionally handle error
    }
  }



  Future<void> updateMessageText(String chatBoxId) async {
    final updatedText = messageController.text.trim();
    if (updatedText.isEmpty) return;

    final msgId = editingMessageId.value;
    if (msgId.isEmpty) return;

    try {
      await ChatRepo.updateMessage(
        chatBoxId: chatBoxId,
        messageId: msgId,
        updatedData: {'messageBody': updatedText},
      );
      cancelEditing(); // Clear after update
    } catch (e) {
      _logger.e('Error updating message: $e'); // Updated logger method
      // Optionally handle error
    }
  }


  void scrollToBottom() {
    if (messageScrollController.hasClients) {
      messageScrollController.animateTo(
          messageScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut);
    }
  }

  FireBaseUserModel? getCachedUser(ChatMetadataModel chat) {
    _logger.i(userCache); // Updated logger method
    final otherMember = chat.members.firstWhereOrNull((m) => m.id != senderId);
    final otherUserId = otherMember?.id ?? '';

    if (otherUserId.isEmpty) return null;

    return userCache[otherUserId];
  }

  void listenToMessages(String chatBoxId) {
    ChatRepo.getOrderedChatsModelList(chatBoxId).listen((messageList) {
      messages.assignAll(messageList);
      update();
    });
  }

  Stream<List<MessageModel>> getOrderedChatsModelList(String chatBoxId) {
    return ChatRepo.getOrderedChatsModelList(chatBoxId);
  }

  @override
  void onInit() {
    super.onInit();

    _init();

    // TextField debounce listener
    messageController.addListener(() {
      debounce<String>(messageController.text.obs, (value) => update(),
          time: Duration(milliseconds: 300));
    });
  }


  Future<void> removeUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userAppId');
  }

  Future<String> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userAppId') ?? '';
  }

  Future<void> saveUserId({required String userId}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userAppId', userId);
    LoggerService.i(prefs.getString('userAppId')); // Logging for debug
  }


  Future<void> _init() async {
    ever(Get.routing.obs, (route) {
      if (route == null || route.current == '/InboxView') {
        userCache.clear();
      }
    });

    senderId = await getUserId();
    update();
  }

  void setListeners() {
    LoggerService.i('Setting Listener');
    listenToInbox();
    update();
  }


  String? extractFirstLink(String message) {
    final RegExp urlRegex = RegExp(r'(https?:\/\/[^\s]+)', caseSensitive: false);

    final match = urlRegex.firstMatch(message);
    if (match != null) {
      return match.group(0);
    }
    return null;
  }

  Future<void> openLinkInBrowser(String url) async {
    final Uri uri = Uri.parse(url.trim());
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        print('Could not launch $url');
      }
    } catch (e) {
      print('Error launching URL: $e');
    }
  }

  bool isLinkMessage(String messageBody) {
    final linkPattern = RegExp(r'https?:\/\/[^\s]+', caseSensitive: false);
    _logger.d(linkPattern.hasMatch(messageBody)); // Updated logger method
    return linkPattern.hasMatch(messageBody);
  }

  Future<FireBaseUserModel?> getOtherUserData(String otherUserId) async {
    if (userCache.containsKey(otherUserId)) {
      return userCache[otherUserId];
    }
    final userData = await ChatRepo.getFireBaseUsersIdOneTime(otherUserId);
    if (userData != null) {
      userCache[otherUserId] = userData;
    }
    return userData;
  }

  void filterChats(String query) {
    searchQuery.value = query.toLowerCase();

    if (query.isEmpty) {
      filteredChats.assignAll(allChats);
      return;
    }

    final result = allChats.where((chat) {
      try {

        // Check Username match
        final otherMember = chat.members.firstWhereOrNull((m) => m.id != senderId);
        final otherUser = otherMember != null ? userCache[otherMember.id] : null;
        final otherUserName = otherUser?.userName?.toLowerCase() ?? '';
        final userNameMatch = otherUserName.contains(query.toLowerCase());

        return  userNameMatch;
      } catch (_) {
        return false;
      }
    }).toList();

    filteredChats.assignAll(result);
  }

  RxBool isInboxLoading = false.obs;

  void listenToInbox() {
    try {
      isInboxLoading.value = true;

      getUserInboxStream().listen((chatList) async {
        allChats.assignAll(chatList);
        filteredChats.assignAll(chatList);

        // Fetch and cache user names in background
        for (var chat in chatList) {
          for (var member in chat.members) {
            if (member.id != senderId && !userCache.containsKey(member.id)) {
              await getOtherUserData(member.id);
            }
          }
        }

        isInboxLoading.value = false;
        _logger.v('Inbox updated$allChats'); // Updated logger method
        update();
      });
    } catch (e) {
      CustomSnackbar.show(
        title: 'Ops! Error occurred',
        message: 'Failed to fetch inbox',
        messageText: ['Failed to fetch inbox'],
      );
      isInboxLoading.value = false;
    }
  }

  String getChatBoxId(String recipientId) {
    List<String> sortedIds = [senderId, recipientId]..sort();
    return sortedIds.join('_');
  }

  void initChatWithUser(
      String receiverId, {
        required String route,
        String? chatBoxId,
        String? userName,
        String? userImage,
      }) {
    String lChatBoxId = chatBoxId ?? getChatBoxId(receiverId);

    Get.toNamed(
      route,
      arguments: ChatViewArguments(
          currentUserId: senderId,
          chatBoxId: lChatBoxId,
          receiverId: receiverId,
          userName: userName,
          userImage: userImage ),
    );
  }


  Future<List<MessageFileModel>?> _sendFiles(
      {required final String messageId,
        required final List<File> files,
        required final String chatBoxId}) async {
    try {
      List<MessageFileModel> uploadedFiles = [];
      bool hasShownLargeFileError = false;
      bool hasShownUnsupportedError = false;

      for (File file in files) {
        if (file.lengthSync() > 10 * 1024 * 1024) {
          if (!hasShownLargeFileError) {
            CustomSnackbar.show(
                title: 'Large file!',
                message: 'File size exceeds 10MB',
                messageText: ['File size exceeds 10MB']);
            hasShownLargeFileError = true;
          }
          continue;
        }

        String extension = fPath.extension(file.path).toLowerCase();
        _logger.d('Sending file ${file.path}'); // Updated logger method
        final storageRef = FirebaseStorage.instance
            .ref('UserChatFiles/$chatBoxId/$messageId/${fPath.basename(file.path)}');
        await storageRef.putFile(file);
        String downloadUrl = await storageRef.getDownloadURL();

        uploadedFiles.add(
          MessageFileModel(
              name: fPath.basename(file.path),
              type: extension.replaceFirst('.', ''),
              id: messageId,
              size: file.lengthSync(),
              link: downloadUrl),
        );
      }

      files.clear();
      return uploadedFiles;
    } catch (e) {
      _logger.e(e); // Updated logger method
      return null;
    }
  }

  Future<void> sendChatWithImageMessage(
      {required String chatBoxId, required String recipientId}) async
  {
    loader.value = true;
    try {
      loader.value = true;
      String messageId = '${DateTime.now().millisecondsSinceEpoch}${Random().nextInt(1000)}';

      // Guard Clause — Prevent Empty Message and No Files
      if ((files == null || (files ?? []).isEmpty) &&
          messageController.text.trim().isEmpty) {
        CustomSnackbar.show(
          title: 'Empty Message',
          message: 'Please enter a message or attach a file',
          messageText: ['Please enter a message or attach a file'],
        );
        return;
      }

      List<MessageFileModel> uploadedFiles = [];
      if (files != null && (files ?? []).isNotEmpty) {
        uploadedFiles = await _sendFiles(
            messageId: messageId, files: files!, chatBoxId: chatBoxId) ??
            [];
      }

      // Consistent Timestamp for everything
      final currentTimestamp = Timestamp.now();

      String finalMessageType = MessageType.text.name;

      if (uploadedFiles.isNotEmpty) {
        final ext = fPath.extension(uploadedFiles.first.name).toLowerCase();
        _logger.v('First File is $ext'); // Updated logger method

        if (ext == '.mp4') {
          finalMessageType = MessageType.video.name;
        } else if (documentExtensions.contains(ext.toLowerCase())) {
          finalMessageType = MessageType.file.name;

        }
        else {
          finalMessageType = MessageType.image.name;
        }
      }

      final MessageModel message = MessageModel(
        messageBody: messageController.text.trim(),
        messageType: finalMessageType,
        messageSenderId: senderId,
        messageReceiverId: recipientId,
        readStatus: ReadStatues.unread.name,
        messageSendTime: FieldValue.serverTimestamp(),
        messageId: messageId,
        messageFiles: uploadedFiles,
        reactions: [],
      );

      if (uploadedFiles.isNotEmpty || message.messageBody.isNotEmpty) {
        final metaData = ChatMetadataModel(
          chatId: chatBoxId,
          chatType: 'direct',
          members: [
            ChatMemberModel(
                id: senderId, role: ChatRole.member, joinedAt: currentTimestamp),
            ChatMemberModel(
                id: recipientId, role: ChatRole.member, joinedAt: currentTimestamp),
          ],
          lastMessage: message.messageBody.isNotEmpty
              ? message.messageBody
              : (uploadedFiles.isNotEmpty ? uploadedFiles.first.name : 'File'),
          lastMessageTime: currentTimestamp,
        );

        await ChatRepo.batchWriteMessageAndMetadata(
            chatBoxId: chatBoxId,
            messageId: messageId,
            messageData: message,
            metaData: metaData);
      }

      rXfile.value = null;
      messageController.clear();
    } catch (e) {
      _logger.e('Error sending message: $e'); // Updated logger method
      CustomSnackbar.show(
          title: 'Ops! Error occurred',
          message: 'Failed to send message',
          messageText: ['Failed to send message']);
    } finally {
      loader.value = false;
    }
  }


  Future<void> forwardMessage(
      {required String chatBoxId, required String recipientId, required MessageModel messageModel}) async
  {
    forwardLoader.value = true;
    try {
      final currentTimestamp = Timestamp.now();

      String messageId = '${DateTime.now().millisecondsSinceEpoch}${Random().nextInt(1000)}';

      final MessageModel message = MessageModel(
        messageBody: messageModel.messageBody,
        messageType: messageModel.messageType,
        messageSenderId: senderId,
        messageReceiverId: recipientId,
        readStatus: ReadStatues.unread.name,
        messageSendTime: FieldValue.serverTimestamp(),
        messageId: messageId,
        messageFiles: messageModel.messageFiles,
        reactions: [],
      );

      if (messageModel.messageFiles.isNotEmpty || messageModel.messageBody.isNotEmpty) {
        final metaData = ChatMetadataModel(
          chatId: chatBoxId,
          chatType: 'direct',
          members: [
            ChatMemberModel(
                id: senderId, role: ChatRole.member, joinedAt: currentTimestamp),
            ChatMemberModel(
                id: recipientId, role: ChatRole.member, joinedAt: currentTimestamp),
          ],
          lastMessage: message.messageBody.isNotEmpty
              ? message.messageBody
              : (messageModel.messageFiles.isNotEmpty ? messageModel.messageFiles.first.name : 'File'),
          lastMessageTime: currentTimestamp,
        );

        await ChatRepo.batchWriteMessageAndMetadata(
            chatBoxId: chatBoxId,
            messageId: messageId,
            messageData: message,
            metaData: metaData);
      }

    } catch (e) {
      _logger.e('Error forwarding message: $e'); // Updated logger method
      CustomSnackbar.show(
          title: 'Ops! Error occurred',
          message: 'Failed to forward message',
          messageText: ['Failed to forward message']);
    } finally {
      forwardLoader.value = false;
    }
  }

  Future<List<File>> pickDocFiles(
      {required List<String> allowedExtensions,
        required bool isMultipleAllow}) async {
    try {
      files?.clear();
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: isMultipleAllow,
        allowedExtensions: allowedExtensions,
      );

      if (result != null && result.files.isNotEmpty) {
        List<File> pickedFiles =
        result.files.where((file) => file.path != null).map((file) => File(file.path!)).toList();

        files?.value = pickedFiles;
        _logger.w("Files: $files"); // Updated logger method
        return pickedFiles;
      }

      return [];
    } catch (e) {
      _logger.e('Error picking documents: $e'); // Updated logger method
      return [];
    }
  }
  
  Future<List<FireBaseUserModel>> getAllUsersofFB()async{
    return await ChatRepo.getAllFireBaseUsers(senderId);
  }

  Future<void> downloadFile(
      String firebaseFileUrl, String localFileName, int index) async {
    loader.value = true;

    try {
      // 1. Ask for permission (Android)
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          CustomSnackbar.show(
            title: 'Permission Denied',
            message: 'Storage permission is required to download the file',
            messageText: ['Storage permission is required'],
          );
          loader.value = false;
          return;
        }
      }

      // 2. Fetch file from Firebase URL
      final response = await http.get(Uri.parse(firebaseFileUrl));
      if (response.statusCode != 200) {
        throw Exception('HTTP Error: ${response.statusCode}');
      }

      // 3. Get Downloads Directory
      final directory = await _getDownloadDirectory();
      final sanitizedFileName = localFileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
      final filePath = '${directory.path}/$sanitizedFileName';
      final file = File(filePath);

      // 4. Write file
      await file.writeAsBytes(response.bodyBytes);

      // 5. Notify success
      CustomSnackbar.show(
        title: 'Downloaded',
        message: 'File saved to Downloads',
        messageText: ['Saved: $sanitizedFileName'],
      );
      _logger.i('File downloaded to: $filePath');
    } catch (e) {
      _logger.e('Error downloading file: $e');
      CustomSnackbar.show(
        title: 'Download Failed',
        message: 'Could not download file',
        messageText: [e.toString()],
      );
    } finally {
      loader.value = false;
    }
  }

// ✅ Cross-platform Downloads folder access
  Future<Directory> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      final downloads = Directory('/storage/emulated/0/Download');
      if (await downloads.exists()) return downloads;
      return await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
    } else if (Platform.isIOS) {
      return await getApplicationDocumentsDirectory();
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
  @override
  void onClose() {
    _unreadSubscription?.cancel();
    messageScrollController.dispose();
    messageController.dispose();
    super.onClose();
  }

  Future<void> updateReadStatus(
      {required String chatBoxId,
        required String messageId,
        required String messageSenderId}) async {
    try {
      if (senderId != messageSenderId) {
        await ChatRepo.updateReadStatus(chatBoxId, messageId, ReadStatues.read.name);
      }
    } catch (e) {
      _logger.e('Error updating read status: $e'); // Updated logger method
    }
  }

  Stream<List<ChatMetadataModel>> getUserInboxStream() {
    if (senderId.isEmpty) return const Stream.empty();
    return ChatRepo.getUserInbox(senderId);
  }


   Future<FireBaseUserModel?> getUserInfo(String userId) async {
    if (userCache.containsKey(userId)) return userCache[userId];

    try {

      FireBaseUserModel?  user=  await  ChatRepo.getFireBaseUsersIdOneTime(userId);

      userCache[userId] = user!=null ? user : null;
      return userCache[userId];
    } catch (e) {
      _logger.e('Failed to get user info: $e');
      return null;
    }
  }

  Future<bool> pickImage(ImageSource imageSource) async {
    try {
      files?.clear();

      final XFile? pickedFile = await picker.pickImage(source: imageSource);
      if (pickedFile != null) {
        files?.add(File(pickedFile.path));
        _logger.w("Files: $files"); // Updated logger method
        return true;
      }
      return false;
    } catch (e) {
      _logger.e('Error picking image: $e'); // Updated logger method
      return false;
    }
  }
}