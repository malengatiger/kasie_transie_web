import 'package:flutter/material.dart';

import '../utils/functions.dart';

class MyFormField extends StatelessWidget {
  const MyFormField(
      {super.key,
        required this.controller,
        required this.label,
        required this.hint,
        required this.icon,
        this.textStyle});

  final TextEditingController controller;
  final String label, hint;
  final Icon icon;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: textStyle == null
          ? myTextStyleMediumLargeWithColor(context, Colors.white, 16)
          : textStyle!,
      decoration: InputDecoration(
        label: Text(label),
        hintText: hint,
        icon: icon,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return hint;
        }
        return null;
      },
    );
  }
}
