import 'package:flutter/material.dart';

class FilledTextField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscureText;
  final bool readOnly;
  final bool isPhone;
  final String hintText;
  final String labelText;
  final String Function(String) validator;
  final VoidCallback onTap;
  final Function(String) onChanged;
  final VoidCallback onEditingComplete;
  final TextInputType textInputType;
  final int maxLines;

  const FilledTextField({
    this.controller,
    this.obscureText = false,
    this.readOnly = false,
    this.hintText,
    this.labelText,
    this.validator,
    this.onTap,
    this.onChanged,
    this.onEditingComplete,
    this.textInputType,
    this.maxLines,
    this.isPhone = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 10.0,
      borderRadius: BorderRadius.all(Radius.circular(10.0)),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        readOnly: readOnly,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: validator,
        maxLines: maxLines,
        onTap: onTap,
        onEditingComplete: onEditingComplete,
        onChanged: onChanged,
        keyboardType: textInputType,
        style: TextStyle(
          fontSize: 18.0,
        ),
        decoration: InputDecoration(
          prefixIcon: isPhone
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 13.0, 10.0, 0.0),
                  child: Text(
                    '+63',
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                )
              : null,
          hintText: hintText,
          labelText: labelText,
          fillColor: Colors.white,
          filled: true,
          isDense: true,
          contentPadding: EdgeInsets.all(12.0),
          labelStyle: TextStyle(
            color: Colors.black,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            borderSide: BorderSide(
              color: Colors.red.shade900,
              width: 3.0,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            borderSide: BorderSide(
              color: Colors.red.shade900,
              width: 2.0,
            ),
          ),
          errorStyle: TextStyle(
            color: Colors.red.shade900,
          ),
        ),
      ),
    );
  }
}
