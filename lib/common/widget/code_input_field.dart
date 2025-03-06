import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CodeInputField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool autoFocus;
  final ValueChanged<String>? onComplete;
  final int index;
  final int totalFields;
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;

  const CodeInputField({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.index,
    required this.totalFields,
    required this.controllers,
    required this.focusNodes,
    this.autoFocus = false,
    this.onComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40.w,
      height: 40.h,
      child: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: (RawKeyEvent event) {
          if (event is RawKeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace) {
            if (controller.text.isEmpty && index > 0) {
              // 当前输入框为空时，删除前一个输入框的内容
              controllers[index - 1].clear();
              FocusScope.of(context).requestFocus(focusNodes[index - 1]);
            }
          }
        },
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.text,
          textCapitalization: TextCapitalization.characters, // 允许大写字母
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp("[0-9A-Z]")), // 仅允许数字和大写字母
            LengthLimitingTextInputFormatter(1), // 限制最多1个字符
          ],
          autofocus: autoFocus,
          decoration: InputDecoration(
            counterText: '',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (value) {
            if (value.isNotEmpty) {
              if (index < totalFields - 1) {
                FocusScope.of(context).requestFocus(focusNodes[index + 1]);
              } else if (index == totalFields - 1) {
                onComplete?.call(value);
              }
            }
          },
        ),
      ),
    );
  }
}
