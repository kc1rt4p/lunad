import 'package:flutter/material.dart';

class LabeledDivider extends StatelessWidget {
  final String text;

  LabeledDivider(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: new Container(
            margin: const EdgeInsets.only(left: 10.0, right: 20.0),
            child: Divider(
              color: Colors.white,
              height: 36,
            ),
          ),
        ),
        Text(
          text,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        Expanded(
          child: new Container(
            margin: const EdgeInsets.only(left: 20.0, right: 10.0),
            child: Divider(
              color: Colors.white,
              height: 36,
            ),
          ),
        ),
      ],
    );
  }
}
