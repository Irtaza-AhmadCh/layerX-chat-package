import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_style.dart';
import '../../utils/logger_services.dart';
import '../../utils/padding_extensions.dart';
import '../../utils/sizedbox_extension.dart';
import '../model/chat_meta_data_model.dart';
import '../view_models/chat_controller.dart';
import '../../widgets/inbox_tile.dart';

class InboxViewWidget extends StatelessWidget {


  // ✅ Customizable UI parts
  final Widget Function(BuildContext, int, ChatMetadataModel)? customTileBuilder;
  final Widget? loadingWidget;
  final Function(String id , String? userName , String? profileUrl) onTileTap;
  final Widget? emptyWidget;
  final EdgeInsetsGeometry? padding;
  final bool autoSortByLatest;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final InboxTileDecoration inboxTileDecoration;
  final SearchFieldDecoration searchFieldDecoration;

  const InboxViewWidget({
    key,
    this.customTileBuilder,
    this.loadingWidget,
    this.emptyWidget,
    this.padding,
    this.autoSortByLatest = true,
    this.physics,
    this.shrinkWrap = false,  required this.onTileTap, required this.inboxTileDecoration, required this.searchFieldDecoration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ChatController controller = Get.find();

    // Set inbox listeners once
    controller.setListeners();
    LoggerService.v('InboxView Opened');

    return Column(
      children: [
        TextFormField(
          onTapOutside: (_) => FocusScope.of(context).unfocus(),
          textInputAction: TextInputAction.search,
          cursorColor: searchFieldDecoration.cursorColor ?? AppColors.primary,
          onChanged:   (val) => controller.filterChats(val),  // ✅ Correct filtering,
          decoration: InputDecoration(
            fillColor: searchFieldDecoration.fillColor ?? AppColors.scaffoldBgColor,
            filled: true,
            prefixIcon: Icon(
              Icons.search,
              color: searchFieldDecoration.prefixIconColor ?? AppColors.textLightBlack,
              size: searchFieldDecoration.iconSize,
            ).paddingFromAll(10.sp),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(searchFieldDecoration.borderRadius ?? 10.sp),
              borderSide: const BorderSide(color: AppColors.transparent),
            ),
            hintText: searchFieldDecoration.hintText ?? 'Search inbox...',
            hintStyle: searchFieldDecoration.hintTextStyle ??
                AppTextStyles.customText16(
                  color: searchFieldDecoration.hintTextColor ?? AppColors.textLightBlack,
                ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(searchFieldDecoration.borderRadius ?? 10.sp),
              borderSide: const BorderSide(color: AppColors.transparent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(searchFieldDecoration.borderRadius ?? 10.sp),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ).paddingBottom(10.h).paddingHorizontal(10.sp),
        Expanded(
          child: Obx(() {
            if (controller.isInboxLoading.value) {
              return loadingWidget ?? const Center(child: CircularProgressIndicator());
            }
          
            final List<ChatMetadataModel> chats = List.from(controller.filteredChats);
          
            // Sort chats by latest message time (optional)
            if (autoSortByLatest) {
              chats.sort((a, b) {
                final Timestamp? timeA = a.lastMessageTime;
                final Timestamp? timeB = b.lastMessageTime;
                if (timeA == null && timeB == null) return 0;
                if (timeA ==     null) return 1;
                if (timeB == null) return -1;
                return timeB.compareTo(timeA);
              });
            }
          
            if (chats.isEmpty) {
              return Center(
                child: emptyWidget ??
                    Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.error , color: AppColors.negativeRed.withValues(alpha: .6), size: 20.h),
                        Text(
                          'No Chat Found',
                          style: AppTextStyles.customText16(fontWeight: FontWeight.w400 , color: AppColors.negativeRed.withValues(alpha: .6)),
                        ),
                  ],
                ),
              );
            }
          
            return GetBuilder<ChatController>(
              builder: (_) {
                return ListView.builder(
                  shrinkWrap: shrinkWrap,
                  physics: physics ?? const BouncingScrollPhysics(),
                  padding: padding ?? EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    final chat = chats[index];
                    if (customTileBuilder != null) {
                      return customTileBuilder!(context, index, chat).paddingBottom(10.h);
                    }
                    return   InboxTile(
                      index: index,
                      chatMetadataModel: chat,
                      onTap: (String id , String? userName, String? profileUrl) {
                      onTileTap(id , userName , profileUrl);
                    }, decoration: InboxTileDecoration(),).paddingBottom(10.h);
                  },
                );
              },
            );
          }),
        ),
      ],
    );
  }
}

class SearchFieldDecoration {
  final Color? backgroundColor;
  final Color? fillColor;
  final Color? cursorColor;
  final Color? prefixIconColor;
  final Color? hintTextColor;
  final double? iconSize;
  final double? borderRadius;
  final TextStyle? hintTextStyle;
  final String? hintText;

  const SearchFieldDecoration({
    this.backgroundColor,
    this.fillColor,
    this.cursorColor,
    this.prefixIconColor,
    this.hintTextColor,
    this.iconSize,
    this.borderRadius,
    this.hintTextStyle,
    this.hintText,
  });
}
