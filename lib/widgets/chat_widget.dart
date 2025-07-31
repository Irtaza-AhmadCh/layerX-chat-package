import 'dart:io';

import 'package:custom_cached_image/custom_cached_image_with_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:layerx_fire_chat/utils/padding_extensions.dart';
import 'package:layerx_fire_chat/utils/sizedbox_extension.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_link_previewer/flutter_link_previewer.dart';

import 'package:flutter_chat_types/flutter_chat_types.dart' show PreviewData;

import '../mvvm/model/message_model.dart';
import '../mvvm/view_models/chat_controller.dart';
import '../utils/app_assets.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_style.dart';
import '../utils/utils.dart';
import 'dialogs/images_dialog.dart';


class DeletedMessageWidget extends StatelessWidget {
  final MessageModel message;

  const DeletedMessageWidget({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSender = message.messageSenderId == Get.find<ChatController>().senderId;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(14.sp),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.block,
            color: Colors.grey.shade600,
            size: 18.sp,
          ),
          8.w.width,
          Expanded(
            child: Text(
              isSender ? "You unsent this message" : "This message was unsent",
              style: AppTextStyles.customText14(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class ImageMessageWidget extends StatefulWidget {

  final MessageModel message;

  const ImageMessageWidget({Key? key, required this.message}) : super(key: key);

  @override
  State<ImageMessageWidget> createState() => _ImageMessageWidgetState();
}

class _ImageMessageWidgetState extends State<ImageMessageWidget> {
  final ChatController controller = Get.find<ChatController>();
  @override
  Widget build(BuildContext context) {
    final images = widget.message.messageFiles
        .where((file) => controller.imageExtensionsForPicker.contains(file.type.toLowerCase()))
        .toList();

    if (images.isEmpty) return const SizedBox();

    return GestureDetector(
      onTap: () => Utils.showCustomDialog(
        context: context,
        child: ImagesDialog(
          imageUrls: images.map((e) => e.link).toList(),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageStack(images),

          ],
      ),
    );
  }

  Widget _buildImageStack(List<MessageFileModel> images) {
    return Stack(
      children: [
        CustomCachedImage(
          imageUrl: images.first.link,
          height: 180.h,
          width: double.infinity,
          borderRadius: 16.sp,
        ),
        if (images.length > 1) _buildImageCountOverlay(images.length),
      ],
    );
  }

  Widget _buildImageCountOverlay(int totalImages) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          borderRadius: BorderRadius.circular(16.sp),
        ),
        child: Center(
          child: Text(
            '+${totalImages - 1}',
            style: AppTextStyles.customText18(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}



class FileMessageWidget extends StatelessWidget {
  final MessageModel message;
  final  int index;
   FileMessageWidget({super.key, required this.message, required this.index});

  String _formatFileSize(int sizeInBytes) {
    if (sizeInBytes < 1024) return '$sizeInBytes B';
    if (sizeInBytes < 1024 * 1024) return '${(sizeInBytes / 1024).toStringAsFixed(1)} KB';
    return '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  final ChatController controller = Get.find<ChatController>();
  String _getFileExtensionIcon(String ext) {
    switch (ext.toLowerCase()) {
      case 'pdf':
        return AppAssets.PDF;
      case 'doc':
      case 'docx':
        return AppAssets.DOC;
      case 'xls':
      case 'xlsx':
        return AppAssets.EXECL;
      default:
        return AppAssets.DOC;
    }
  }

  Future<void> _openFileExternally(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {

      // CustomSnackBar.show(message: 'Could not open file');
      // Optionally show error/snackbar
    }
  }

  @override
  Widget build(BuildContext context) {
    final file = message.messageFiles.firstOrNull;
    if (file == null) return const SizedBox();

    final iconPath = _getFileExtensionIcon(file.name.split('.').last);
    final fileSize = _formatFileSize(file.size);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _openFileExternally(file.link),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16.sp),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            padding: EdgeInsets.symmetric(horizontal: 14.sp, vertical: 12.sp),
            child: Row(
              children: [
                Container(
                  height: 42.sp,
                  width: 42.sp,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10.sp),
                  ),
                  child: Center(
                    child: SvgPicture.asset(iconPath, height: 24.sp, width: 24.sp, fit: BoxFit.contain),
                  ),
                ),
                10.w.width,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        file.name,
                        style: AppTextStyles.customText14(fontWeight: FontWeight.w500, color: AppColors.black),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      4.h.height,
                      Text(
                        '${fileSize} • ${file.name.split('.').last.toUpperCase()}',
                        style: AppTextStyles.customText10(color: AppColors.textLightBlack),
                      ),
                    ],
                  ),
                ),
                10.w.width,
                GestureDetector(
                  onTap: () => controller.downloadFile(file.link , file.name, index),
                  child: Icon(Icons.download_rounded, color: AppColors.primary, size: 20.sp),
                ),
              ],
            ),
          ),
        ),

      ],
    );
  }
}



class LinkMessageWidget extends StatefulWidget {
  final MessageModel message;


  const LinkMessageWidget({
    super.key,

    required this.message,

  });

  @override
  State<LinkMessageWidget> createState() => _LinkMessageWidgetState();
}

class _LinkMessageWidgetState extends State<LinkMessageWidget> {
  final ChatController controller = Get.find<ChatController>();
  PreviewData? _previewData;

  @override
  Widget build(BuildContext context) {

    String? link = controller.extractFirstLink(widget.message.messageBody);
    bool isMe = widget.message.messageSenderId== controller.senderId;

    return Align(
      child: Column(
        crossAxisAlignment:isMe? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          GestureDetector(
            
            onTap: () async {

                controller.openLinkInBrowser(link ?? 'www.youtube.com');
            },
            child: Container(
              decoration: BoxDecoration(
                color:AppColors.white,
                borderRadius: BorderRadius.circular(14.sp),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinkPreview(
                    enableAnimation: true,
                    onPreviewDataFetched: (data) {
                      setState(() {
                        _previewData = data;
                      });
                    },
                    previewData: _previewData,
                    text: link ?? '',
                    width: Get.width * 0.7,
                  ),
                ],
              ),
            ),
          ),
          5.h.height,
        ],
      ).paddingHorizontal(8.w).paddingVertical(5.h),
    );
  }
}

