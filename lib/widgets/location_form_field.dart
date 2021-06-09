import 'package:flutter/material.dart';

buildLocationFormField({
  FocusNode focusNode,
  TextEditingController controller,
  VoidCallback onTap,
  String hintText,
  Widget prefixIcon,
  String labelText,
  Color labelColor = Colors.white,
}) {
  return TextFormField(
    focusNode: focusNode,
    controller: controller,
    readOnly: true,
    onTap: onTap,
    style: TextStyle(
      color: Colors.white,
    ),
    decoration: InputDecoration(
      isDense: true,
      contentPadding: EdgeInsets.zero,
      labelStyle: TextStyle(
        fontWeight: focusNode.hasFocus ? FontWeight.bold : null,
        fontSize: 16.0,
        fontFamily: 'Poppins',
        color: labelColor,
      ),
      hintStyle: TextStyle(
        fontSize: 14.0,
        color: Colors.white70,
      ),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      border: UnderlineInputBorder(
        borderRadius: BorderRadius.zero,
      ),
      enabledBorder: UnderlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: Colors.white70),
      ),
      focusedBorder: UnderlineInputBorder(
        borderRadius: BorderRadius.zero,
      ),
      alignLabelWithHint: true,
      hintText: hintText,
      fillColor: Colors.redAccent.shade700,
      filled: true,
      prefixIcon: prefixIcon,
      labelText: labelText,
    ),
  );
}
