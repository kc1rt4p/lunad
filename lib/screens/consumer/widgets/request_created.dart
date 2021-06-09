import 'package:flutter/material.dart';
import 'package:lunad/widgets/filled_button.dart';

buildRequestCreated(
    BuildContext context, double screenHeight, double screenWidth) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 25.0),
    height: screenHeight,
    width: double.infinity,
    color: Colors.red.shade600,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.send_rounded,
          color: Colors.white,
          size: screenWidth * .4,
        ),
        SizedBox(height: 20.0),
        Text(
          'Your request has been successfully submitted and is being processed, a rider will be assigned shortly',
          textScaleFactor: 1.2,
          textAlign: TextAlign.center,
          style: TextStyle(
            wordSpacing: 1.2,
            letterSpacing: 1.2,
            height: 1.5,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 35.0),
        Container(
          width: screenWidth * .6,
          child: buildFilledButton(
            label: 'Back to Home',
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ),
      ],
    ),
  );
}
