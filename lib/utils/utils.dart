/// Provides utility functions for the LayerX app.
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';


class Utils {
  static String formatDate(DateTime? date) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(date ?? DateTime.now());
  }

  static String formatDateDMY(DateTime? date) {
    final DateFormat formatter = DateFormat('dd-MM-yyyy');
    return formatter.format(date ?? DateTime.now());
  }

  static calculateAge(DateTime birthDate) {
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;

    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  static String? formatDateTime(DateTime? date) {
    if (date == null) return null;
    return DateFormat('MMM d, h:mm a').format(date); // e.g., Apr 18, 3:45 PM
  }

  static bool isNotExpired(String date) {
    try {
      final cleanedDate = date
          .replaceAll(RegExp(r's+'), '') // Remove all spaces
          .replaceAll(RegExp(r'[./]'), '-') // Replace '/' and '.' with '-'
          .trim();

      final DateTime inputDate = DateTime.parse(cleanedDate);

      final DateTime today = DateTime.now();
      final DateTime currentDate = DateTime(today.year, today.month, today.day);

      return inputDate.isAfter(currentDate) ||
          inputDate.isAtSameMomentAs(currentDate);
    } catch (e) {
      return false;
    }
  }

  static void showBottomSheet(
      {required BuildContext context, required Widget child , bool? isDismissable} ) {
    showModalBottomSheet(

      isScrollControlled: isDismissable?? true,
      isDismissible: isDismissable ?? true, // Prevents dismiss on barrier tap
      enableDrag: isDismissable ?? true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(30.sp),
              topLeft: Radius.circular(30.sp))),
      context: context,
      builder: (context) {
        return Container(
          width: ScreenUtil().screenWidth,
          child: child,
        );
      },
    );
  }

  static void showCustomDialog(
      {required BuildContext context, required Widget child}) {
    showDialog(
      context: context,

      barrierDismissible: true, // Allows dismissing when tapping outside
      builder: (context) {
        return Dialog(
          insetPadding: EdgeInsets.all(20.w),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22.sp), // Rounded corners for the dialog
          ),
          child: child, // Your custom widget inside the dialog
        );
      },
    );
  }



  static Future<void> showPickImageOptionsDialog(
    BuildContext context, {
    required VoidCallback onCameraTap,
    required VoidCallback onGalleryTap,
    VoidCallback? onFileTap, // <-- made nullable
    bool? hasFile, // <-- nullable param
    VoidCallback? onVideoTap, // <-- made nullable
    bool? hasVideo, // <-- nullable param
  }) async {
    await showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: onCameraTap,
            child: const Text("Camera"),
          ),
          CupertinoActionSheetAction(
            onPressed: onGalleryTap,
            child: const Text("Gallery"),
          ),

          if (hasFile == true && onFileTap != null) // <-- safe null check
            CupertinoActionSheetAction(
              onPressed: onFileTap,
              child: const Text("Pick File (PDF, DOC)"),
            ),
          if (hasVideo == true && onVideoTap != null) // <-- safe null check
            CupertinoActionSheetAction(
              onPressed: onVideoTap,
              child: const Text("Video"),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Cancel"),
        ),
      ),
    );
  }


  static Future<void> showPickVideoOptionsDialog(
      BuildContext context, {
        required VoidCallback onCameraTap,
        required VoidCallback onGalleryTap,
      }) async {
    await showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: onCameraTap,
            child: const Text("Record Video"),
          ),
          CupertinoActionSheetAction(
            onPressed: onGalleryTap,
            child: const Text("Pick Video from Gallery"),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Cancel"),
        ),
      ),
    );
  }

  static showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
