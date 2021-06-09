import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class CompletedRequest extends Equatable {
  final String id;
  final String consumerName;
  final String type;
  final double amountCollected;
  final int totalDuration;
  final String dateCompleted;
  final double totalDistance;

  CompletedRequest({
    this.id,
    this.consumerName,
    this.type,
    this.amountCollected,
    this.totalDuration,
    this.dateCompleted,
    this.totalDistance,
  });

  factory CompletedRequest.fromDocument(DocumentSnapshot doc) {
    final docData = doc.data();
    return CompletedRequest(
      id: doc.id,
      consumerName: docData['consumerName'],
      type: docData['type'],
      amountCollected: docData['amountCollected'],
      totalDuration: docData['totalDuration'],
      dateCompleted: docData['dateCompleted'],
      totalDistance: docData['totalDistance'],
    );
  }

  @override
  // TODO: implement props
  List<Object> get props => [
        id,
        consumerName,
        type,
        amountCollected,
        totalDuration,
        dateCompleted,
        totalDistance,
      ];
}
