import 'package:flutter/material.dart';

class StyledButton extends StatelessWidget {
  final Color textColor;
  final Color backgroundColor;
  final String label;
  final VoidCallback onTap;

  const StyledButton({
    this.textColor = Colors.red,
    this.backgroundColor = Colors.white,
    this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
            return backgroundColor;
          }),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        onPressed: onTap,
      ),
    );

    // return GestureDetector(
    //   onTap: () => onTap,
    //   child: Material(
    //     color: backgroundColor,
    //     elevation: 10.0,
    //     borderRadius: BorderRadius.circular(10.0),
    //     child: Container(
    //       height: 40.0,
    //       width: double.infinity,
    //       decoration: BoxDecoration(
    //         color: Colors.white,
    //         borderRadius: BorderRadius.circular(10.0),
    //       ),
    //       child: Row(
    //         mainAxisAlignment: MainAxisAlignment.center,
    //         children: [
    //           Expanded(
    //             child: Text(
    //               label,
    //               style: TextStyle(
    //                 color: Colors.redAccent.shade700,
    //                 fontWeight: FontWeight.bold,
    //               ),
    //             ),
    //           ),
    //         ],
    //       ),
    //     ),
    //   ),
    // );
  }
}
