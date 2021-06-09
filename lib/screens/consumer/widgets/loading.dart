import 'package:flutter/material.dart';
import 'package:progress_indicators/progress_indicators.dart';

buildLoading(BuildContext context, double screenHeight, double screenWidth) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 25.0),
    height: screenHeight,
    width: double.infinity,
    color: Colors.red.shade600,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        HeartbeatProgressIndicator(
          child: SizedBox(
            width: screenWidth * .3,
            child: Image.asset('assets/images/logo_white.png'),
          ),
        )
      ],
    ),
  );
}
