import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lunad/data/models/user.dart';

class Rider extends User {
  final List<double> currentLocation;
  final bool isAvailable;
  final List<String> services;

  Rider({
    String id,
    String type,
    String displayName,
    String phoneNum,
    String firstName,
    String lastName,
    this.currentLocation,
    this.isAvailable,
    this.services,
  }) : super(
          displayName: displayName,
          id: id,
          type: type,
          phoneNum: phoneNum,
          firstName: firstName,
          lastName: lastName,
        );

  @override
  Map<String, dynamic> toMap() {
    final riderMap = super.toMap();

    riderMap.addAll({
      'currentLocation': this.currentLocation,
      'isAvailable': this.isAvailable,
      'services': this.services,
    });

    return riderMap;
  }

  @override
  factory Rider.fromDocument(DocumentSnapshot doc) {
    final docData = doc.data();
    return Rider(
      id: doc.id,
      type: docData['type'],
      phoneNum: docData['phoneNum'],
      displayName: docData['displayName'],
      firstName: docData['firstName'],
      lastName: docData['lastName'],
      currentLocation: docData['currentLocation'] != null
          ? List.from(docData['currentLocation'])
          : null,
      isAvailable: docData['isAvailable'] ?? null,
      services:
          docData['services'] != null ? List.from(docData['services']) : null,
    );
  }
}
