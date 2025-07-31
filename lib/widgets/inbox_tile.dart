import 'package:custom_cached_image/custom_cached_image_with_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:layerx_fire_chat/utils/padding_extensions.dart';
import 'package:layerx_fire_chat/utils/sizedbox_extension.dart';
import 'package:shimmer/shimmer.dart';
import '../mvvm/model/chat_meta_data_model.dart';
import '../mvvm/view_models/chat_controller.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_style.dart';

class InboxTile extends StatelessWidget {
  final int index;
  final ChatMetadataModel chatMetadataModel;
  final InboxTileDecoration decoration;
  final Function(String id ,  String? userName, String? profileUrl) onTap;

  const InboxTile({
    Key? key,
    required this.index,
    required this.chatMetadataModel,
    required this.decoration,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ChatController controller = Get.find<ChatController>();
    final user = controller.getCachedUser(chatMetadataModel);

    final userName = user?.userName ?? 'User';
    final userImage = user?.profileImage ?? '';
    final lastMessage = chatMetadataModel.lastMessage ?? 'No message yet';

    final lastTime = chatMetadataModel.lastMessageTime?.toDate();
    final timeString = lastTime != null
        ? "${lastTime.hour.toString().padLeft(2, '0')}:${lastTime.minute.toString().padLeft(2, '0')}"
        : '';

    final double tileHeight = decoration.height ?? 75.h;
    final double avatarSize = decoration.imageSize ?? 55.sp;
    final double radius = decoration.borderRadius ?? 10.sp;
    final Color tileColor = decoration.backgroundColor ?? AppColors.white;

    if (user == null) {
      return Animate(
        effects: [
          FadeEffect(duration: 250.ms + (index * 50).ms),
          SlideEffect(duration: 250.ms + (index * 50).ms, begin: const Offset(0, 0.4)),
          ScaleEffect(duration: 250.ms + (index * 70).ms),
        ],
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: tileHeight,
            decoration: BoxDecoration(
              color: tileColor,
              borderRadius: BorderRadius.circular(radius),
            ),
          ).paddingBottom(6.h),
        ),
      );
    }

    return Animate(
      effects: [
        FadeEffect(duration: 250.ms + (index * 100).ms, curve: Curves.easeInOut),
        SlideEffect(duration: 250.ms + (index * 100).ms, curve: Curves.easeInOut, begin: const Offset(0, 0.4)),
        ScaleEffect(duration: 250.ms + (index * 100).ms, curve: Curves.easeOutBack),
      ],
      child: GestureDetector(
        onTap: () {
          final otherMember = chatMetadataModel.members.firstWhereOrNull((m) => m.id != controller.senderId);
          final otherUserId = otherMember?.id ?? '';
          onTap(otherUserId ,  userName ,  userImage );
        },
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: tileColor,
                borderRadius: BorderRadius.circular(radius),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CustomCachedImage(
                        height: avatarSize,
                        width: avatarSize,
                        imageUrl: userImage,
                        borderRadius: avatarSize / 2,
                      ),
                      10.w.width,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: decoration.userNameStyle ??
                                AppTextStyles.customText18(
                                  color: AppColors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          SizedBox(
                            width: 170.w,
                            child: Text(
                              lastMessage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: decoration.messageStyle ??
                                  AppTextStyles.customText12(
                                    color: AppColors.textLightBlack,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      5.w.width,
                      Text(
                        timeString,
                        style: decoration.timeStyle ??
                            AppTextStyles.customText10(
                              color: AppColors.textLightBlack,
                            ),
                      ),
                    ],
                  ),
                ],
              ).paddingFromAll(decoration.padding ?? 10.sp),
            ),
          ],
        ),
      ),
    );
  }
}


class InboxTileDecoration {
  final double? height;
  final double? imageSize;
  final double? borderRadius;
  final double? padding;
  final Color? backgroundColor;
  final TextStyle? userNameStyle;
  final TextStyle? jobIdStyle;
  final TextStyle? messageStyle;
  final TextStyle? timeStyle;

  const InboxTileDecoration({
    this.height,
    this.imageSize,
    this.borderRadius,
    this.padding,
    this.backgroundColor,
    this.userNameStyle,
    this.jobIdStyle,
    this.messageStyle,
    this.timeStyle,
  });
}
