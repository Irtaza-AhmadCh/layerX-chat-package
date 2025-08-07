import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:layerx_fire_chat/mvvm/view_models/chat_controller.dart';
import 'package:layerx_fire_chat/utils/app_colors.dart';
import 'package:layerx_fire_chat/utils/padding_extensions.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../mvvm/model/ui_models.dart';
import '../../utils/app_text_style.dart';
import '../inbox_tile.dart';

class ForwardMessageDialog extends StatelessWidget {
  final Function(String otherUserId) onTileTap;
  final ChatController controller = Get.find();

  ForwardMessageDialog({super.key, required this.onTileTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: .65.sh,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(30.sp)
      ),
      child: Column(
        children: [
          /// Dialog title
          Text(
            'Forward to...',
            style: AppTextStyles.customText22(color: AppColors.black , fontWeight: FontWeight.w600),
          ).paddingSymmetric(vertical: 16.h),
    
          /// Search Bar
          TextFormField(
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
            textInputAction: TextInputAction.search,
            cursorColor: AppColors.primary,
            onChanged: controller.filterChats,
            decoration: InputDecoration(
              fillColor: AppColors.scaffoldBgColor,
              filled: true,
              prefixIcon: Icon(
                Icons.search,
                color: AppColors.textLightBlack,
                size: 24.sp,
              ).paddingFromAll(10.sp),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.sp),
                borderSide: const BorderSide(color: AppColors.transparent),
              ),
              hintText: 'Search inbox...',
              hintStyle: AppTextStyles.customText16(
                color: AppColors.textLightBlack,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.sp),
                borderSide: const BorderSide(color: AppColors.transparent),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.sp),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ).paddingBottom(10.h).paddingHorizontal(10.sp),
    
          /// Inbox List
          Expanded(
            child: Obx(() {
              final chats = controller.filteredChats;
              if (chats.isEmpty) {
                return Center(
                  child: Text(
                    'No Inbox found.',
                    style: AppTextStyles.customText14(
                        color: AppColors.textLightBlack),
                  ),
                );
              }
    
              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 10.sp),
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  final chat = chats[index];
                  return  InboxTile(
                      index: index,
                      chatMetadataModel: chat,
                      onTap: (otherUserId, userName, profileUrl) {
                        onTileTap(otherUserId);
                        Get.back(); // Close dialog after selection
                      },
                      decoration: InboxTileDecoration(),
                    ).paddingBottom(10.h);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
