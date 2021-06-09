import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class DeliveryInformation extends Equatable {
  final String id;
  final String receiverName;
  final String receiverPhoneNumber;
  final String itemDescription;
  final double itemDeclaredValue;
  final String deliveryRemarks;
  final String paymentFrom;
  final double serviceFee;
  final double deliveryFee;
  final double totalAmount;
  final DateTime dateCompleted;

  DeliveryInformation({
    this.id,
    this.receiverName,
    this.receiverPhoneNumber,
    this.itemDescription,
    this.itemDeclaredValue,
    this.deliveryRemarks,
    this.paymentFrom,
    this.serviceFee,
    this.deliveryFee,
    this.totalAmount,
    this.dateCompleted,
  });

  @override
  List<Object> get props => [
        id,
        receiverName,
        receiverPhoneNumber,
        itemDescription,
        itemDeclaredValue,
        deliveryRemarks,
        paymentFrom,
        serviceFee,
        deliveryFee,
        totalAmount,
        dateCompleted,
      ];

  factory DeliveryInformation.fromDocument(DocumentSnapshot docSnapshot) {
    Map docData = docSnapshot.data();
    return DeliveryInformation(
      id: docSnapshot.id,
      receiverName: docData['receiverName'],
      receiverPhoneNumber: docData['receiverPhoneNumber'],
      itemDescription: docData['itemDescription'],
      itemDeclaredValue: docData['itemDeclaredValue'],
      deliveryRemarks: docData['deliveryRemarks'],
      paymentFrom: docData['paymentFrom'],
      serviceFee: docData['serviceFee'],
      deliveryFee: docData['requestFee'],
      totalAmount: docData['totalAmount'],
      dateCompleted: docData['dateCompleted'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'receiverName': this.receiverName,
      'receiverPhoneNumber': this.receiverPhoneNumber,
      'itemDescription': this.itemDescription,
      'itemDeclaredValue': this.itemDeclaredValue,
      'deliveryRemarks': this.deliveryRemarks,
      'paymentFrom': this.paymentFrom,
      'serviceFee': this.serviceFee,
      'deliveryFee': this.deliveryFee,
      'totalAmount': this.totalAmount,
      'dateCompleted': this.dateCompleted,
    };
  }
}
