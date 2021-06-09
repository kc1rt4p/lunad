import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lunad/data/models/consumer_request.dart';

Container buildRequestItem(ConsumerRequest request) {
  return Container(
    margin: EdgeInsets.only(bottom: 10.0),
    padding: EdgeInsets.all(8.0),
    color: Colors.red.shade400,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              request.type.toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Spacer(),
            Text(
              DateFormat.yMMMd()
                  .add_jm()
                  .format(request.dateRequested.toDate()),
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
        Divider(color: Colors.white54),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Pick-Up Time',
              style: TextStyle(
                color: Colors.white70,
              ),
            ),
            Text(
              request.pickUpDate != null
                  ? DateFormat.yMMMd()
                      .add_jm()
                      .format(request.pickUpDate.toDate())
                  : 'ASAP',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              request.type == 'errand' ? 'Store Address' : 'Pick-up Address',
              style: TextStyle(
                color: Colors.white70,
              ),
            ),
            Text(
              request.pickUpAddress,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Drop-off Address',
              style: TextStyle(
                color: Colors.white70,
              ),
            ),
            Text(
              request.dropOffAddress,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Total Amount',
              style: TextStyle(
                color: Colors.white70,
              ),
            ),
            Text(
              '₱${request.totalAmount.toStringAsFixed(2)}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ),
            ),
          ],
        ),
        Divider(color: Colors.white54),
        Center(
          child: Text(
            request.status.toUpperCase(),
            style: TextStyle(
              color: Colors.white,
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}
