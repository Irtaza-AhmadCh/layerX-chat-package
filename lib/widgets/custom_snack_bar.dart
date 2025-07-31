import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CustomSnackbar {
  static void show({
    String? title,
    String? message,
    Color? backgroundColor,
    IconData? iconData,
    Color? iconColor,
    List<String>? messageText,
    Color? textColor,
    double? borderRadius,
    Color? borderColor,
    void Function(GetSnackBar)? onTap,
    Duration? animationDuration,
    Duration? displayDuration,
    SnackPosition? position,
    String? emoji,
  }) {
    // Default values
    final bgColor = backgroundColor ?? Colors.black.withOpacity(0.85);
    final txtColor = textColor ?? Colors.white;
    final border = borderRadius ?? 16.sp;
    final iconClr = iconColor ?? Colors.white;
    final displayTime = displayDuration ?? const Duration(seconds: 3);
    final animTime = animationDuration ?? const Duration(milliseconds: 600);
    final snackPosition = position ?? SnackPosition.BOTTOM;
    final displayEmoji = emoji ?? "🔥"; // Default emoji, only used if no iconData

    // Custom snackbar widget with direction-aware layout
    Widget customSnackWidget = Builder(
      builder: (context) {
        return ZoomIn(
          duration: animTime,
          from: 0.8,
          child: Directionality(
            textDirection: Directionality.of(context),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    bgColor,
                    bgColor.withOpacity(0.8),
                    bgColor.withRed(255).withOpacity(0.9), // Flaming red tint
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(border),
                border: Border.all(
                  color: borderColor ?? Colors.orangeAccent.withOpacity(0.5),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.4), // Flaming glow
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Flaming background effect
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(border),
                      child: Pulse(
                        duration: const Duration(seconds: 2),
                        infinite: true,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [
                                Colors.transparent,
                                Colors.orange.withOpacity(0.2),
                                Colors.red.withOpacity(0.1),
                              ],
                              radius: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Content
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Icon with ShakeX and sparkle effect
                        if (iconData != null)
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              // Sparkle effect
                              Pulse(
                                duration: const Duration(seconds: 1),
                                infinite: true,
                                child: Container(
                                  height: 50.sp,
                                  width: 50.sp,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        Colors.yellow.withOpacity(0.4),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              ShakeX(
                                duration: const Duration(seconds: 2),
                                child: Container(
                                  height: 40.sp,
                                  width: 40.sp,
                                  decoration: BoxDecoration(
                                    color: bgColor.withOpacity(0.7),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: iconClr.withOpacity(0.5),
                                        blurRadius: 12,
                                        spreadRadius: 3,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Icon(
                                      iconData,
                                      color: iconClr,
                                      size: 26.sp,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ).paddingSymmetric(horizontal: 12.w),

                        // Text content with staggered animations
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Title with Bounce animation
                              Bounce(
                                duration: const Duration(milliseconds: 800),
                                delay: const Duration(milliseconds: 200),
                                child: Text(
                                  title ?? "Oops!",
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: txtColor,
                                    fontWeight: FontWeight.w800,
                                    height: 1.1,
                                  ),
                                ),

                              ),

                              SizedBox(height: 6.h),

                              // Message with SlideInLeft animation
                              SlideInLeft(
                                duration: const Duration(milliseconds: 700),
                                delay: const Duration(milliseconds: 300),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: messageText != null
                                      ? messageText.asMap().entries.map((entry) {
                                    return Padding(
                                      padding: EdgeInsets.only(bottom: 4.h),
                                      child: Text(
                                        entry.value,
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: txtColor.withOpacity(0.9),
                                          fontWeight: FontWeight.w400,
                                          height: 1.3,
                                        ),
                                      ),

                                    );
                                  }).toList()
                                      : [
                                    Text(
                                      message ?? "Something went wrong!",
                                      style: TextStyle(
                                        color: txtColor.withOpacity(0.9),
                                        fontWeight: FontWeight.w400,
                                        height: 1.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Close button with Rotate animation
                        Spin(
                          duration: const Duration(milliseconds: 600),
                          delay: const Duration(milliseconds: 400),
                          child: InkWell(
                            onTap: () => Get.back(),
                            borderRadius: BorderRadius.circular(20.sp),
                            child: Container(
                              padding: EdgeInsets.all(6.sp),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.redAccent,
                                    Colors.orangeAccent,
                                  ],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.orange.withOpacity(0.4),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: Text(
                                "✕",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Progress indicator with flaming effect
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: TweenAnimationBuilder<double>(
                      duration: displayTime,
                      curve: Curves.easeOut,
                      tween: Tween<double>(begin: 0, end: 1),
                      builder: (context, value, child) {
                        return LinearProgressIndicator(
                          value: value,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.orangeAccent.withOpacity(0.7),
                          ),
                          minHeight: 4,
                          borderRadius: BorderRadius.circular(2),
                        );
                      },
                    ),
                  ),

                  // Flaming emoji with Dance animation, only shown if no iconData
                  if (iconData == null)
                    Positioned(
                      top: -25.sp,
                      right: 15.sp,
                      child: Dance(
                        infinite: true,
                        duration: const Duration(seconds: 2),
                        child: Container(
                          height: 40.sp,
                          width: 40.sp,
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [
                                Colors.yellow.withOpacity(0.6),
                                Colors.red.withOpacity(0.4),
                                Colors.transparent,
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              displayEmoji,
                              style: TextStyle(fontSize: 24.sp),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );

    // Use GetX's snackbar with our custom widget
    Get.snackbar(
      "",
      "",
      isDismissible: true,
      duration: displayTime,
      snackPosition: snackPosition,
      backgroundColor: Colors.transparent,
      barBlur: 0,
      overlayBlur: 0,
      padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
      snackStyle: SnackStyle.FLOATING,
      animationDuration: animTime,
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInCirc,
      userInputForm: Form(child: customSnackWidget),
      onTap: onTap ?? (snack) {},
    );
  }

  // Error snackbar
  static void showError({
    String? title,
    String? message,
    List<String>? messageList,
    IconData? iconData,
  }) {
    show(
      title: title ?? "Error",
      message: message,
      messageText: messageList,
      backgroundColor: Colors.red.shade900,
      iconData: iconData ?? Icons.error_outline_rounded,
      iconColor: Colors.white,
      borderColor: Colors.red.shade700,
      emoji: "💥",
    );
  }

  // Success snackbar
  static void showSuccess({
    String? title,
    String? message,
    List<String>? messageList,
    IconData? iconData,
  }) {
    show(
      title: title ?? "Success",
      message: message,
      messageText: messageList,
      backgroundColor: Colors.green.shade800,
      iconData: iconData ?? Icons.check_circle_outline_rounded,
      iconColor: Colors.white,
      borderColor: Colors.green.shade600,
      emoji: "🎉",
    );
  }

  // Info snackbar
  static void showInfo({
    String? title,
    String? message,
    List<String>? messageList,
    IconData? iconData,
  }) {
    show(
      title: title ?? "Information",
      message: message,
      messageText: messageList,
      backgroundColor: Colors.blue.shade800,
      iconData: iconData ?? Icons.info_outline_rounded,
      iconColor: Colors.white,
      borderColor: Colors.blue.shade600,
      emoji: "ℹ️",
    );
  }

  // Warning snackbar
  static void showWarning({
    String? title,
    String? message,
    List<String>? messageList,
    IconData? iconData,
  }) {
    show(
      title: title ?? "Warning",
      message: message,
      messageText: messageList,
      backgroundColor: Colors.amber.shade900,
      iconData: iconData ?? Icons.warning_amber_rounded,
      borderColor: Colors.amber.shade700,
      emoji: "⚠️",
    );
  }
}
