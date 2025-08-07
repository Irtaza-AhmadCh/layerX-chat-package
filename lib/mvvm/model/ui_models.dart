import 'package:flutter/material.dart';
import '../model/message_model.dart'; // Update this path as needed

class ChatViewDecorations {
  // UI Customization
  final Color? sendButtonColor;
  final Color? sendIconColor;
  final double? sendIconSize;
  final Color? inputFieldBgColor;
  final String? inputHint;
  final TextStyle? inputHintStyle;
  final TextStyle? inputTextStyle;
  final Color? fileChipBgColor;
  final TextStyle? fileTextStyle;
  final Color? fileIconColor;
  final Widget? customLoadingIndicator;
  final Widget? customFileIcon;
  final Widget? customSendButton;

  // Optional Behavior and Layout
  final Widget? loadingWidget;
  final Widget? emptyWidget;
  final Widget Function(BuildContext context, int index, MessageModel message)? customTileBuilder;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;

  const ChatViewDecorations({
    this.sendButtonColor,
    this.sendIconColor,
    this.sendIconSize,
    this.inputFieldBgColor,
    this.inputHint,
    this.inputHintStyle,
    this.inputTextStyle,
    this.fileChipBgColor,
    this.fileTextStyle,
    this.fileIconColor,
    this.customLoadingIndicator,
    this.customFileIcon,
    this.customSendButton,
    this.loadingWidget,
    this.emptyWidget,
    this.customTileBuilder,
    this.shrinkWrap = false,
    this.physics,
    this.padding,
  });
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
