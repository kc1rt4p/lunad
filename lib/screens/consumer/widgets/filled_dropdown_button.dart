import 'package:flutter/material.dart';

Column buildFilledDropDown(
    {String labelText,
    List<DropdownMenuItem<String>> items,
    String value,
    Function(String) onChanged}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
      DropdownButtonFormField<String>(
        dropdownColor: Colors.red.shade600,
        style: TextStyle(
          color: Colors.white,
        ),
        iconEnabledColor: Colors.white,
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
        ),
        isExpanded: true,
        value: value,
        onChanged: onChanged,
        items: items,
      ),
    ],
  );
}
