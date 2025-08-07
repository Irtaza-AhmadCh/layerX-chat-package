import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_cached_image/custom_cached_image_with_shimmer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:layerx_fire_chat/utils/logger_services.dart';
import 'package:layerx_fire_chat/utils/sizedbox_extension.dart';
import 'package:layerx_fire_chat/utils/utils.dart';
import 'package:logger/logger.dart';
import '../mvvm/model/message_model.dart';
import '../mvvm/view_models/chat_controller.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_style.dart';
import 'chat_widget.dart';
import 'dialogs/forward_message_dialog.dart';


class MessageBubbleDecoration {
  final double? avatarSize;
  final double? borderRadius;
  final String? dateFormate;
  final Color? sentMessageColor;
  final Color? receivedMessageColor;
  final TextStyle? messageTextStyle;
  final TextStyle? timeTextStyle;
  final EdgeInsetsGeometry? padding;
  final double? maxBubbleWidthFactor;

  const MessageBubbleDecoration({
    this.dateFormate,
    this.avatarSize,
    this.borderRadius,
    this.sentMessageColor,
    this.receivedMessageColor,
    this.messageTextStyle,
    this.timeTextStyle,
    this.padding,
    this.maxBubbleWidthFactor,
  });
}


class MessageBubble extends StatefulWidget {
  final MessageModel message;
  final String chatBoxId;
  final String? profileImg;
  final ChatController controller;
  final MessageBubbleDecoration decoration;
  final int index;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.chatBoxId,
    required this.controller,
    this.profileImg,
    required this.decoration, required this.index,
  }) : super(key: key);

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  @override
  void initState() {
    super.initState();
    widget.controller.updateReadStatus(
      chatBoxId: widget.chatBoxId,
      messageId: widget.message.messageId,
      messageSenderId: widget.message.messageSenderId,
    );
  }

  Widget content() {
    if (widget.message.isSending ?? false) {
      LoggerService.wtf('Local Message');
      return const MediaLoaderMessageWidget();
    }


    if (widget.message.messageType == MessageType.text.name.toString()) {
      if (widget.controller.isLinkMessage(widget.message.messageBody)) {
        return LinkMessageWidget(message: widget.message);
      } else {
        return 0.width;
      }
    } else if (widget.message.messageType == MessageType.image.name.toString()) {
      return ImageMessageWidget(message: widget.message);
    } else if (widget.message.messageType == MessageType.file.name.toString()) {
      return FileMessageWidget(message: widget.message , index:  widget.index,);
    } else if (widget.message.messageType == MessageType.deleted.name.toString()) {
      return DeletedMessageWidget(message: widget.message);
    } else {
      return 0.width;
    }
  }

  String formatTimestampToTime(Timestamp timestamp) {
    final DateTime dateTime = timestamp.toDate();
    return DateFormat(widget.decoration.dateFormate ?? 'HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {


    final bool isDeleted = widget.message.messageType == MessageType.deleted.name.toString();
    final double avatarSize = widget.decoration.avatarSize ?? 42.sp;
    final double radius = widget.decoration.borderRadius ?? 10.sp;
    final EdgeInsetsGeometry padding = widget.decoration.padding ?? EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h);
    final Color sentColor = widget.decoration.sentMessageColor ?? AppColors.white;
    final Color receivedColor = widget.decoration.receivedMessageColor ?? AppColors.primaryLight;
    final TextStyle messageStyle = widget.decoration.messageTextStyle ??
        AppTextStyles.customText14(color: AppColors.black, fontWeight: FontWeight.w400);
    final TextStyle timeStyle = widget.decoration.timeTextStyle ??
        AppTextStyles.customText12(color: Colors.black.withOpacity(0.3));
    final double maxWidthFactor = widget.decoration.maxBubbleWidthFactor ?? 0.66;

    return Obx(() {
      bool isMe = widget.message.messageSenderId == widget.controller.senderId.value;
      bool isSelected = widget.controller.isSelected(widget.message.messageId); // <- must be inside

      return GestureDetector(
        onLongPress:isDeleted ? null : () {
          widget.controller.toggleSelectedMessage(widget.message.messageId);
        },
        onTap: () {
          if (isSelected) {
            widget.controller.toggleSelectedMessage(widget.message.messageId);
          }
        },
        child: Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isMe) ...[
                CustomCachedImage(
                  height: avatarSize,
                  width: avatarSize,
                  imageUrl: widget.profileImg ?? '',
                  borderRadius: 16.sp,
                ),
                10.w.width,
              ],
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: ScreenUtil().screenWidth * maxWidthFactor,
                        ),
                        padding: padding,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(radius),
                            topRight: Radius.circular(radius),
                            bottomRight: Radius.circular(!isMe ? radius : 2),
                            bottomLeft: Radius.circular(isMe ? radius : 2),
                          ),
                          color: isSelected
                              ? Colors.grey.withOpacity(0.4)
                              : (isMe ? sentColor : receivedColor),
                        ),
                        child: Column(
                          crossAxisAlignment:
                          isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                          children: [
                            content(),
                            isDeleted ? 0.width :   3.h.height,
                           isDeleted ? 0.width :  Text(widget.message.messageBody, style: messageStyle),
                          ],
                        ),
                      ),
                      if (isSelected && !isDeleted )
                        Positioned(
                          right: isMe ? 4.w : null,
                          left: !isMe ? 4.w : null,
                          top: 4.h,
                          child: Row(
                            children: [

                              _iconButton(CupertinoIcons.share_solid, () {
                                Utils.showCustomDialog(context: context, child:
                                ForwardMessageDialog(
                                  onTileTap: (
                                    String otherUserId) {
                                    widget.controller.forwardMessage(chatBoxId: widget.chatBoxId, recipientId:otherUserId , messageModel: widget.message);
                                  },));
                                // forward action
                              }),
                              if (isMe)
                                _iconButton(Icons.delete, () {
                                  // widget.controller.
                                  widget.controller.deleteMessage(widget.chatBoxId);
                                  // delete action
                                }),
                              if (isMe)
                                _iconButton(Icons.edit, () {
                                  print('tap');
                                  widget.controller.startEditingMessage(widget.message);
                                }),



                            ],
                          ),
                        ),
                    ],
                  ),
                  Text(
                    formatTimestampToTime(
                        (widget.message.messageSendTime ?? Timestamp.now()) as Timestamp),
                    style: timeStyle,
                  ),
                  10.h.height,
                ],
              ),
            ],
          ),
        ).animate(),
      );
    });

  }

  Widget _iconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        padding: EdgeInsets.all(6.sp),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 16.sp),
      ),
    );
  }

}
