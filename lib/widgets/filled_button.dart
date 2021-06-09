import 'package:flutter/material.dart';

MaterialButton buildFilledButton({
  String label,
  Function onPressed,
  Color labelColor = Colors.black,
}) {
  return MaterialButton(
    minWidth: double.infinity,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
    elevation: 2.0,
    color: Colors.white,
    textColor: labelColor,
    child: Text(
      label,
      textScaleFactor: 1.1,
      style: TextStyle(
        fontFamily: 'Poppins',
      ),
    ),
    onPressed: onPressed,
  );
}
