import 'package:flutter/material.dart';

Column buildModalTextField({
  TextEditingController controller,
  TextInputType keyboardType,
  String labelText,
  String hintText,
  int maxLines = 1,
  Function validator,
  Function(String) onChanged,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: EdgeInsets.only(left: 8.0),
        child: Text(
          labelText,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      SizedBox(height: 5.0),
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: TextStyle(
          color: Colors.white,
        ),
        validator: (val) {
          if (val.trim().isEmpty) {
            return 'This field is required';
          }
          return null;
        },
        onChanged: onChanged,
        cursorColor: Colors.white,
        decoration: InputDecoration(
          fillColor: Colors.red.shade400,
          filled: true,
          isDense: true,
          contentPadding: EdgeInsets.all(10.0),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Colors.red.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Colors.red.shade400),
          ),
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.white60,
          ),
        ),
      ),
    ],
  );
}
