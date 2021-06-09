import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String type;
  final String displayName;
  final String phoneNum;
  final String firstName;
  final String lastName;

  User({
    this.id,
    this.type,
    this.displayName,
    this.phoneNum,
    this.firstName,
    this.lastName,
  });

  @override
  List<Object> get props => [
        id,
        type,
        displayName,
        phoneNum,
        firstName,
        lastName,
      ];

  factory User.fromDocument(DocumentSnapshot docSnapshot) {
    Map docData = docSnapshot.data();
    return User(
      id: docSnapshot.id,
      type: docData['type'],
      displayName: docData['displayName'],
      phoneNum: docData['phoneNum'],
      firstName: docData['firstName'],
      lastName: docData['lastName'],
    );
  }

  /// fromEntity - This method creates the POJO back from the entity object
  Map<String, dynamic> toMap() {
    return {
      type: this.type,
      displayName: this.displayName,
      phoneNum: this.phoneNum,
      firstName: this.firstName,
      lastName: this.lastName,
    };
  }
}
