import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ConsumerRequest extends Equatable {
  final String id;
  final String type;
  final Timestamp dateRequested;
  final String dateRequestedString;
  final Timestamp pickUpDate;
  final String pickUpAddress;
  final List<double> pickUpLatLng;
  final String dropOffAddress;
  final List<double> dropOffLatLng;
  final String consumerId;
  final String consumerName;
  final String riderId;
  final String riderName;
  final String riderPhoneNumber;
  final List<double> riderCurrentLocation;
  final Timestamp dateProcessed;
  final Timestamp datePickedUp;
  final Timestamp dateAccepted;
  final Timestamp dateCompleted;
  final Timestamp dateCancelled;
  final int totalDuration;
  final double totalDistance;
  final double totalAmount;
  final String status;

  ConsumerRequest({
    this.id,
    this.type,
    this.dateRequested,
    this.dateRequestedString,
    this.pickUpDate,
    this.pickUpAddress,
    this.pickUpLatLng,
    this.dropOffAddress,
    this.dropOffLatLng,
    this.consumerId,
    this.consumerName,
    this.riderId,
    this.riderName,
    this.riderPhoneNumber,
    this.riderCurrentLocation,
    this.dateProcessed,
    this.datePickedUp,
    this.dateAccepted,
    this.dateCompleted,
    this.dateCancelled,
    this.totalDuration,
    this.totalDistance,
    this.totalAmount,
    this.status,
  });

  @override
  List<Object> get props => [
        id,
        type,
        dateRequested,
        dateRequestedString,
        pickUpDate,
        pickUpAddress,
        pickUpLatLng,
        dropOffAddress,
        dropOffLatLng,
        consumerId,
        consumerName,
        riderId,
        riderName,
        riderPhoneNumber,
        riderCurrentLocation,
        dateProcessed,
        datePickedUp,
        dateAccepted,
        dateCompleted,
        dateCancelled,
        totalDuration,
        totalDistance,
        totalAmount,
        status,
      ];

  factory ConsumerRequest.fromDocument(DocumentSnapshot docSnapshot) {
    Map docData = docSnapshot.data();
    return ConsumerRequest(
      id: docSnapshot.id,
      type: docData['type'],
      dateRequested: docData['dateRequested'],
      dateRequestedString: docData['dateRequestedString'],
      pickUpDate: docData['pickUpDate'],
      pickUpAddress: docData['pickUpAddress'],
      pickUpLatLng: List.from(docData['pickUpLatLng']),
      dropOffAddress: docData['dropOffAddress'],
      dropOffLatLng: List.from(docData['dropOffLatLng']),
      dateProcessed: docData['dateProcessed'],
      consumerId: docData['consumerId'],
      consumerName: docData['consumerName'],
      riderId: docData['riderId'],
      riderName: docData['riderName'],
      riderPhoneNumber: docData['riderPhoneNumber'],
      riderCurrentLocation: docData['riderCurrentLocation'] != null
          ? List.from(docData['riderCurrentLocation'])
          : null,
      datePickedUp: docData['datePickedUp'],
      dateAccepted: docData['dateAccepted'],
      dateCompleted: docData['dateCompleted'],
      dateCancelled: docData['dateCancelled'],
      totalDuration: docData['totalDuration'],
      totalDistance: docData['totalDistance'],
      totalAmount: docData['totalAmount'],
      status: docData['status'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': this.type,
      'dateRequested': this.dateRequested,
      'dateRequestedString': this.dateRequestedString,
      'pickUpDate': this.pickUpDate,
      'pickUpAddress': this.pickUpAddress,
      'pickUpLatLng': this.pickUpLatLng,
      'dropOffAddress': this.dropOffAddress,
      'dateProcessed': this.dateProcessed,
      'dropOffLatLng': this.dropOffLatLng,
      'datePickUp': this.datePickedUp,
      'dateAccepted': this.dateAccepted,
      'consumerId': this.consumerId,
      'consumerName': this.consumerName,
      'riderId': this.riderId,
      'riderName': this.riderName,
      'riderPhoneNumber': this.riderPhoneNumber,
      'riderCurrentLocation': this.riderCurrentLocation,
      'dateCompleted': this.dateCompleted,
      'dateCancelled': this.dateCancelled,
      'totalDuration': this.totalDuration,
      'totalDistance': this.totalDistance,
      'totalAmount': this.totalAmount,
      'status': this.status,
    };
  }
}
