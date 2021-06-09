import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class TransportInformation extends Equatable {
  final String id;
  final double distance;
  final double serviceFee;
  final double transportFee;
  final double totalAmount;
  final DateTime dateCompleted;

  TransportInformation({
    this.id,
    this.distance,
    this.serviceFee,
    this.transportFee,
    this.totalAmount,
    this.dateCompleted,
  });

  @override
  List<Object> get props => [
        id,
        distance,
        serviceFee,
        transportFee,
        totalAmount,
        dateCompleted,
      ];

  factory TransportInformation.fromDocument(DocumentSnapshot docSnapshot) {
    final docData = docSnapshot.data();
    return TransportInformation(
      id: docSnapshot.id,
      distance: docData['distance'],
      serviceFee: docData['serviceFee'],
      transportFee: docData['transportFee'],
      totalAmount: docData['totalAmount'],
      dateCompleted: docData['dateCompleted'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'distance': this.distance,
      'serviceFee': this.serviceFee,
      'transportFee': this.transportFee,
      'totalAmount': this.totalAmount,
      'dateCompleted': this.dateCompleted,
    };
  }
}
