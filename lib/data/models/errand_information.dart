import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ErrandInformation extends Equatable {
  final String id;
  final String storeName;
  final String itemDescription;
  final double estimatedPrice;
  final String remarks;
  final String receiverName;
  final String receriverPhoneNumber;
  final double serviceFee;
  final double errandFee;
  final double totalFee;
  final DateTime dateCompleted;

  ErrandInformation({
    this.id,
    this.storeName,
    this.itemDescription,
    this.estimatedPrice,
    this.remarks,
    this.receiverName,
    this.receriverPhoneNumber,
    this.serviceFee,
    this.errandFee,
    this.totalFee,
    this.dateCompleted,
  });

  @override
  List<Object> get props => [
        id,
        storeName,
        itemDescription,
        estimatedPrice,
        remarks,
        receiverName,
        receriverPhoneNumber,
        serviceFee,
        errandFee,
        totalFee,
        dateCompleted,
      ];

  factory ErrandInformation.fromDocument(DocumentSnapshot docSnapshot) {
    final docData = docSnapshot.data();

    return ErrandInformation(
      id: docSnapshot.id,
      storeName: docData['storeName'],
      itemDescription: docData['itemDescription'],
      estimatedPrice: docData['estimatedPrice'],
      remarks: docData['remarks'],
      receiverName: docData['receiverName'],
      receriverPhoneNumber: docData['receriverPhoneNumber'],
      serviceFee: docData['serviceFee'],
      errandFee: docData['errandFee'],
      totalFee: docData['totalFee'],
      dateCompleted: docData['dateCompleted'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'storeName': this.storeName,
      'itemDescription': this.itemDescription,
      'estimatedPrice': this.estimatedPrice,
      'remarks': this.remarks,
      'receiverName': this.receiverName,
      'receriverPhoneNumber': this.receriverPhoneNumber,
      'serviceFee': this.serviceFee,
      'errandFee': this.errandFee,
      'totalFee': this.totalFee,
      'dateCompleted': this.dateCompleted,
    };
  }
}

class ErrandItem extends Equatable {
  final String id;
  final String name;
  final String qty;

  ErrandItem({
    this.id,
    this.name,
    this.qty,
  });

  factory ErrandItem.fromDocument(DocumentSnapshot docSnapshot) {
    final docData = docSnapshot.data();
    return ErrandItem(
      id: docSnapshot.id,
      name: docData['name'],
      qty: docData['qty'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': this.name,
      'qty': this.qty,
    };
  }

  @override
  List<Object> get props => [
        id,
        name,
        qty,
      ];
}
