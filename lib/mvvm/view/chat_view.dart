import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:layerx_fire_chat/mvvm/model/chat_view_argument_model.dart';
import 'package:layerx_fire_chat/mvvm/model/ui_models.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_text_style.dart';
import '../../utils/utils.dart';
import '../../utils/padding_extensions.dart';
import '../../utils/sizedbox_extension.dart';
import '../../widgets/message_bubble.dart';
import '../model/message_model.dart';
import '../view_models/chat_controller.dart';

class ChatViewWidget extends StatefulWidget {
  final ChatViewArguments chatViewArguments;
  final MessageBubbleDecoration? messageBubbleDecoration;
  final ChatViewDecorations? decorations;



  const ChatViewWidget({
    super.key,
    required this.chatViewArguments,
    this.messageBubbleDecoration,
    this.decorations,
  });


  @override
  State<ChatViewWidget> createState() => _ChatViewWidgetState();
}

class _ChatViewWidgetState extends State<ChatViewWidget> {
  final ChatController chatController = Get.find<ChatController>();

  @override
  void initState() {
    super.initState();
    chatController.scrollToBottom();
    chatController.listenToMessages(widget.chatViewArguments.chatBoxId);
    chatController.messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    // return Column(
    //   children: [
    //     20.h.height,
    //
    //     // 🔄 Chat Messages
    //     // Expanded(
    //     //
    //     //   child: StreamBuilder<List<MessageModel>>(
    //     //     stream: chatController.getOrderedChatsModelList(widget.chatViewArguments.chatBoxId),
    //     //     builder: (context, snapshot) {
    //     //       if (snapshot.connectionState == ConnectionState.waiting) {
    //     //         return const Center(child: CircularProgressIndicator());
    //     //       }
    //     //       if (!snapshot.hasData || snapshot.data!.isEmpty) {
    //     //         return Center(
    //     //           child: Text(
    //     //             'No message yet',
    //     //             style: AppTextStyles.customText16(
    //     //               color: AppColors.textLightBlack,
    //     //               fontWeight: FontWeight.w500,
    //     //             ),
    //     //           ),
    //     //         );
    //     //       }
    //     //       final messages = snapshot.data!;
    //     //       WidgetsBinding.instance.addPostFrameCallback((_) {
    //     //         Future.delayed(const Duration(milliseconds: 100), () {
    //     //           chatController.scrollToBottom();
    //     //         });
    //     //       });
    //     //
    //     //       return ListView.builder(
    //     //         controller: chatController.messageScrollController,
    //     //         itemCount: messages.length,
    //     //         itemBuilder: (context, index) {
    //     //           return MessageBubble(
    //     //             index: index,
    //     //             message: messages[index],
    //     //             controller: chatController,
    //     //             profileImg: widget.chatViewArguments.userImage,
    //     //             chatBoxId: widget.chatViewArguments.chatBoxId, decoration: widget.messageBubbleDecoration ?? MessageBubbleDecoration(),
    //     //           );
    //     //         },
    //     //       );
    //     //     },
    //     //   ),
    //     // ),
    //     Expanded(
    //       child: Obx(() {
    //         if (chatController.isInboxLoading.value) {
    //           return loadingWidget ?? const Center(child: CupertinoActivityIndicator());
    //         }
    //
    //         final List<MessageModel> chats = List.from(chatController.messagesList);
    //
    //
    //         if (chats.isEmpty) {
    //           return Center(
    //             child: emptyWidget ??
    //                 Column(
    //                   mainAxisAlignment: MainAxisAlignment.center,
    //                   crossAxisAlignment: CrossAxisAlignment.center,
    //                   children: [
    //                     Icon(CupertinoIcons.chat_bubble_fill, color: AppColors.textLightBlack, size: 40.h),
    //                     Text(
    //                       ' Start Chat',
    //                       style: AppTextStyles.customText16(fontWeight: FontWeight.w400, color: AppColors.textLightBlack),
    //                     ),
    //                   ],
    //                 ),
    //           );
    //         }
    //
    //         return GetBuilder<ChatController>(
    //             builder: (_) {
    //               return ListView.builder(
    //                 shrinkWrap: shrinkWrap,
    //                 physics: physics ?? const BouncingScrollPhysics(),
    //                 padding: padding ?? EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
    //                 itemCount: chats.length,
    //                 itemBuilder: (context, index) {
    //                   final chat = chats[index];
    //                   if (customTileBuilder != null) {
    //                     return customTileBuilder!(context, index, chat).paddingBottom(10.h);
    //                   }
    //                   return MessageBubble(
    //                     index: index,
    //                     message: chatController.messagesList[index],
    //                     controller: chatController,
    //                     profileImg: widget.chatViewArguments.userImage,
    //                     chatBoxId: widget.chatViewArguments.chatBoxId,
    //                     decoration: widget.messageBubbleDecoration ?? MessageBubbleDecoration(),
    //                   );
    //                 },
    //               );
    //             });
    //       }),),
    //     10.h.height,
    //
    //     // 📎 File Preview Row
    //     Obx(() {
    //       if (chatController.files == null || chatController.files!.isEmpty) {
    //         return const SizedBox.shrink();
    //       }
    //
    //       return Container(
    //         margin: EdgeInsets.symmetric(vertical: 8.h),
    //         padding: EdgeInsets.all(10.sp),
    //         decoration: BoxDecoration(
    //           color: AppColors.white,
    //           borderRadius: BorderRadius.circular(12.sp),
    //           boxShadow: [
    //             BoxShadow(
    //               color: Colors.black.withOpacity(0.05),
    //               blurRadius: 5,
    //               offset: const Offset(0, 2),
    //             ),
    //           ],
    //         ),
    //         child: SingleChildScrollView(
    //           scrollDirection: Axis.horizontal,
    //           child: Row(
    //             children: chatController.files!.map((file) {
    //               final fileName = file.path.split('/').last;
    //               return Container(
    //                 margin: EdgeInsets.only(right: 8.w),
    //                 padding:
    //                 EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
    //                 decoration: BoxDecoration(
    //                   color: widget.fileChipBgColor ??
    //                       AppColors.primary.withOpacity(0.1),
    //                   borderRadius: BorderRadius.circular(8.sp),
    //                 ),
    //                 child: Row(
    //                   mainAxisSize: MainAxisSize.min,
    //                   children: [
    //                     Icon(
    //                       Icons.insert_drive_file,
    //                       color:
    //                       widget.fileIconColor ?? AppColors.primary,
    //                       size: 20.sp,
    //                     ),
    //                     6.w.width,
    //                     ConstrainedBox(
    //                       constraints: BoxConstraints(maxWidth: 100.w),
    //                       child: Text(
    //                         fileName,
    //                         style: widget.fileTextStyle ??
    //                             AppTextStyles.customText12(
    //                                 color: Colors.black),
    //                         overflow: TextOverflow.ellipsis,
    //                       ),
    //                     ),
    //                     6.w.width,
    //                     GestureDetector(
    //                       onTap: () => chatController.files?.remove(file),
    //                       child: Icon(Icons.close,
    //                           size: 16.sp, color: Colors.red),
    //                     ),
    //                   ],
    //                 ),
    //               );
    //             }).toList(),
    //           ),
    //         ),
    //       );
    //     }),
    //
    //     // 📝 Input Area + 📤 Send Button
    //     Row(
    //       children: [
    //         // Input Field
    //         Expanded(
    //           child: TextField(
    //             focusNode: chatController.messageFieldFocusNode,
    //             controller: chatController.messageController,
    //             style: widget.inputTextStyle ??
    //                 AppTextStyles.customText16(color: Colors.black),
    //             decoration: InputDecoration(
    //               suffixIcon: GestureDetector(
    //                 onTap: () {
    //                   Utils.showPickImageOptionsDialog(
    //                     context,
    //                     onCameraTap: () async {
    //                       Get.back();
    //                       await chatController.pickImage(ImageSource.camera);
    //                     },
    //                     onGalleryTap: () async {
    //                       Get.back();
    //                       chatController.files?.value =
    //                       await chatController.pickDocFiles(
    //                         allowedExtensions:
    //                         chatController.imageExtensionsForPicker,
    //                         isMultipleAllow: true,
    //                       );
    //                     },
    //                     onFileTap: () async {
    //                       Get.back();
    //                       chatController.files?.value =
    //                       await chatController.pickDocFiles(
    //                         allowedExtensions: chatController
    //                             .documentExtensionsFonsForPicker,
    //                         isMultipleAllow: false,
    //                       );
    //                     },
    //                     hasFile: true,
    //                   );
    //                 },
    //                 child: (widget.customFileIcon ??
    //                     Icon(Icons.file_copy,
    //                         size: 24.sp, color: AppColors.black))
    //                     .paddingFromAll(12.sp),
    //               ),
    //               filled: true,
    //               fillColor: widget.inputFieldBgColor ?? AppColors.white,
    //
    //               hintText:
    //               widget.inputHint ?? "Share your thoughts...",
    //               hintStyle: widget.inputHintStyle ??
    //                   AppTextStyles.customText14(
    //                       color: Colors.black.withOpacity(0.7)),
    //               border: OutlineInputBorder(
    //                 borderRadius: BorderRadius.circular(30.sp),
    //                 borderSide: BorderSide.none,
    //               ),
    //               focusedBorder: OutlineInputBorder(
    //                 borderRadius: BorderRadius.circular(30.sp),
    //                 borderSide: BorderSide(color: AppColors.primary),
    //               ),
    //               enabledBorder: OutlineInputBorder(
    //                 borderRadius: BorderRadius.circular(30.sp),
    //                 borderSide: BorderSide.none,
    //               ),
    //               contentPadding:
    //               EdgeInsets.symmetric(horizontal: 10.w, vertical: 14.sp),
    //             ),
    //           ),
    //         ),
    //
    //         8.w.width,
    //
    //         // Send Button
    //         Obx(
    //               () => chatController.loader.value
    //               ? (widget.customLoadingIndicator ??
    //               const CircularProgressIndicator(
    //                   color: AppColors.primary))
    //               : GestureDetector(
    //             onTap: () async {
    //               HapticFeedback.mediumImpact();
    //               if (chatController.editingMessageId.isNotEmpty) {
    //                 await chatController.updateMessageText(widget.chatViewArguments.chatBoxId);
    //               } else {
    //               await chatController.sendChatWithImageMessage(
    //                 chatBoxId: widget.chatViewArguments.chatBoxId,
    //                 recipientId: widget.chatViewArguments.receiverId,
    //               );
    //               }
    //             },
    //             child: widget.customSendButton ??
    //                 Container(
    //                   decoration: BoxDecoration(
    //                     color: widget.sendButtonColor ??
    //                         AppColors.darkBlueColor,
    //                     shape: BoxShape.circle,
    //                   ),
    //                   child: Icon(Icons.send,
    //                       color: widget.sendIconColor ??
    //                           AppColors.white,
    //                       size: widget.sendIconSize ?? 30.sp)
    //                       .paddingFromAll(10.sp),
    //                 ),
    //           ),
    //         ),
    //       ],
    //     ).paddingBottom(20.sp),
    //   ],
    // ).paddingHorizontal(15.w);

    return Column(
      children: [
        20.h.height,

        Expanded(
          child: Obx(() {


            final List<MessageModel> chats = List.from(chatController.messagesList);

            if (chats.isEmpty) {
              return Center(
                child: widget.decorations?.emptyWidget ??
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.chat_bubble_fill, color: AppColors.textLightBlack, size: 40.h),
                        Text(
                          ' Start Chat',
                          style: AppTextStyles.customText16(fontWeight: FontWeight.w400, color: AppColors.textLightBlack),
                        ),
                      ],
                    ),
              );
            }

            return ListView.builder(
              shrinkWrap: widget.decorations?.shrinkWrap ?? false,
              physics: widget.decorations?.physics ?? const BouncingScrollPhysics(),
              padding: widget.decorations?.padding ?? EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
              controller: chatController.messageScrollController,
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                if (widget.decorations?.customTileBuilder != null) {
                  return widget.decorations!.customTileBuilder!(context, index, chat).paddingBottom(10.h);
                }
                return MessageBubble(
                  index: index,
                  message: chat,
                  controller: chatController,
                  profileImg: widget.chatViewArguments.userImage,
                  chatBoxId: widget.chatViewArguments.chatBoxId,
                  decoration: widget.messageBubbleDecoration ?? MessageBubbleDecoration(),
                );
              },
            );
          }),
        ),
        // 📎 File Preview Row
            Obx(() {
              if ((chatController.files == null || chatController.files!.isEmpty) || chatController.loader.value ) {
                return const SizedBox.shrink();
              }

              return Container(
                margin: EdgeInsets.symmetric(vertical: 8.h),
                padding: EdgeInsets.all(10.sp),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12.sp),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: chatController.files!.map((file) {
                      final fileName = file.path.split('/').last;
                      return Container(
                        margin: EdgeInsets.only(right: 8.w),
                        padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: widget.decorations?.fileChipBgColor ??
                              AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.sp),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.insert_drive_file,
                              color:
                              widget.decorations?.fileIconColor ?? AppColors.primary,
                              size: 20.sp,
                            ),
                            6.w.width,
                            ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: 100.w),
                              child: Text(
                                fileName,
                                style: widget.decorations?.fileTextStyle ??
                                    AppTextStyles.customText12(
                                        color: Colors.black),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            6.w.width,
                            GestureDetector(
                              onTap: () => chatController.files?.remove(file),
                              child: Icon(Icons.close,
                                  size: 16.sp, color: Colors.red),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            }),

        // 📝 Input + Send Button
        Row(
          children: [
            // Text Input Field
            Expanded(
              child: TextField(
                focusNode: chatController.messageFieldFocusNode,
                controller: chatController.messageController,
                style: widget.decorations?.inputTextStyle ?? AppTextStyles.customText16(color: Colors.black),
                decoration: InputDecoration(
                  suffixIcon: GestureDetector(
                    onTap: () {
                      if((chatController.files ?? []).isEmpty) {
                        Utils.showPickImageOptionsDialog(
                        context,
                        onCameraTap: () async {
                          Get.back();
                          await chatController.pickImage(ImageSource.camera);
                        },
                        onGalleryTap: () async {
                          Get.back();
                          chatController.files?.value = await chatController.pickDocFiles(
                            allowedExtensions: chatController.imageExtensionsForPicker,
                            isMultipleAllow: true,
                          );
                        },
                        onFileTap: () async {
                          Get.back();
                          chatController.files?.value = await chatController.pickDocFiles(
                            allowedExtensions: chatController.documentExtensionsFonsForPicker,
                            isMultipleAllow: false,
                          );
                        },
                        hasFile: true,
                      );
                      }
                    },
                    child: (widget.decorations?.customFileIcon ??
                        Icon(Icons.file_copy, size: 24.sp, color: AppColors.black))
                        .paddingFromAll(12.sp),
                  ),
                  filled: true,
                  fillColor: widget.decorations?.inputFieldBgColor ?? AppColors.white,
                  hintText: widget.decorations?.inputHint ?? "Share your thoughts...",
                  hintStyle: widget.decorations?.inputHintStyle ?? AppTextStyles.customText14(color: Colors.black.withOpacity(0.7)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.sp),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.sp),
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.sp),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 14.sp),
                ),
              ),
            ),

            8.w.width,

            // Send Button
            // Obx(() {
            //   return
                // chatController.loader.value
                //   ? (widget.decorations?.customLoadingIndicator ??
                //   const CircularProgressIndicator(color: AppColors.primary))
                //   :
              GestureDetector(
                onTap: () async {
                  HapticFeedback.mediumImpact();
                  if (chatController.editingMessageId.isNotEmpty) {
                    await chatController.updateMessageText(widget.chatViewArguments.chatBoxId);
                  } else {
                    await chatController.sendChatWithImageMessage(
                      chatBoxId: widget.chatViewArguments.chatBoxId,
                      recipientId: widget.chatViewArguments.receiverId,
                    );
                  }
                },
                child: widget.decorations?.customSendButton ??
                    Container(
                      decoration: BoxDecoration(
                        color: widget.decorations?.sendButtonColor ?? AppColors.darkBlueColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.send,
                          color: widget.decorations?.sendIconColor ?? AppColors.white,
                          size: widget.decorations?.sendIconSize ?? 30.sp)
                          .paddingFromAll(10.sp),
                    ),
              // );
            // }
            ),

          ],
        ).paddingBottom(20.sp),
      ],
    ).paddingHorizontal(15.w);

  }
}
