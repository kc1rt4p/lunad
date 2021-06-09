import 'package:flutter/material.dart';
import 'package:lunad/data/models/errand_information.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

showItemsToPurchase(
    BuildContext context, List<ErrandItem> items, String storeName) {
  Alert(
    context: context,
    title: 'Items to Purchase',
    desc: storeName.toUpperCase(),
    type: AlertType.none,
    style: AlertStyle(
      buttonAreaPadding: EdgeInsets.zero,
      alertPadding: EdgeInsets.zero,
      titleTextAlign: TextAlign.left,
      isOverlayTapDismiss: false,
      isButtonVisible: false,
    ),
    closeIcon: Icon(Icons.close),
    content: Container(
      padding: EdgeInsets.all(10.0),
      child: Column(
        children: items.map((item) {
          return Column(
            children: [
              SizedBox(height: 10.0),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                  Text(
                    item.qty,
                    style: TextStyle(
                      fontSize: 14.0,
                    ),
                  ),
                ],
              ),
              Divider(color: Colors.black54),
            ],
          );
        }).toList(),
      ),
    ),
    closeFunction: () => Navigator.pop(context),
  ).show();
}
