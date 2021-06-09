import 'package:flutter/material.dart';

class LunadLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        FractionallySizedBox(
          widthFactor: 0.85,
          child: Image.asset(
            'assets/images/logo_white.png',
            color: Colors.black38,
          ),
        ),
        FractionallySizedBox(
          widthFactor: 0.9,
          child: Image.asset('assets/images/logo_white.png'),
        ),
      ],
    );
  }
}
