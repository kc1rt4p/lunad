import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

Tooltip buildIconButton({
  Function onTap,
  IconData icon,
  String tooltip,
}) {
  return Tooltip(
    message: tooltip,
    child: GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          FaIcon(
            icon,
            color: Colors.black38,
            size: 35,
          ),
          FaIcon(
            icon,
            color: Colors.red.shade900,
            size: 32,
          ),
          FaIcon(
            icon,
            color: Colors.white,
            size: 29.0,
          ),
        ],
      ),
    ),
  );
}
