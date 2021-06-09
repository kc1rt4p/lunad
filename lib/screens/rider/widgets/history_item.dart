import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lunad/data/models/completed_request.dart';

Card buildHistoryItem(CompletedRequest request, Color backgroundColor,
    Color fontColor, bool show) {
  return Card(
    color: backgroundColor,
    child: Column(
      children: [
        Visibility(
          visible: show ?? true,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.red.shade400,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(3.0),
                topRight: Radius.circular(3.0),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            width: double.infinity,
            child: Center(
              child: Text(
                DateFormat.yMMMMd()
                    .format(DateFormat.yMd().parse(request.dateCompleted)),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.userAlt,
                    color: fontColor,
                  ),
                  SizedBox(width: 10.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.consumerName,
                          style: TextStyle(
                            color: fontColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                        Text(
                          'Customer',
                          style: TextStyle(
                            color: fontColor.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  FaIcon(
                    FontAwesomeIcons.briefcase,
                    color: fontColor,
                  ),
                  SizedBox(width: 10.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.type.toUpperCase(),
                          style: TextStyle(
                            color: fontColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                        Text(
                          'Type',
                          style: TextStyle(
                            color: fontColor.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.0),
              Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.receipt,
                    color: fontColor,
                  ),
                  SizedBox(width: 10.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '₱${(request.amountCollected * .93).toStringAsFixed(2)}',
                          style: TextStyle(
                            color: fontColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                        Text(
                          'Income',
                          style: TextStyle(
                            color: fontColor.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  FaIcon(
                    FontAwesomeIcons.solidClock,
                    color: fontColor,
                  ),
                  SizedBox(width: 10.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${(request.totalDuration ?? 0 / 60).toStringAsFixed(2)} mins',
                          style: TextStyle(
                            color: fontColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                        Text(
                          'Total Duration',
                          style: TextStyle(
                            color: fontColor.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
