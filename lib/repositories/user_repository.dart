import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lunad/data/models/rider.dart';
import 'package:lunad/data/models/user.dart';

final _usersRef = FirebaseFirestore.instance.collection('users');

class UserRepository {
  UserRepository();

  Future<User> getUser(String id) async {
    try {
      final userDoc = await _usersRef.doc(id).get();
      if (!userDoc.exists) return null;
      return User.fromDocument(userDoc);
    } catch (e) {
      print('error getting user info: ${e.toString()}');
      return null;
    }
  }

  Future<Rider> getRider(String id) async {
    try {
      final riderDoc = await _usersRef.doc(id).get();
      print(riderDoc);
      if (!riderDoc.exists) return null;
      return Rider.fromDocument(riderDoc);
    } catch (e) {
      print('error getting rider: ${e.toString()}');
      return null;
    }
  }

  Future<bool> userExists(String id) async {
    try {
      final result = await _usersRef.doc(id).get();
      return result.exists;
    } catch (e) {
      print('error check if user exists: ${e.toString()}');
      return null;
    }
  }

  Future<User> createUser(User user) async {
    try {
      await _usersRef.doc(user.id).set({
        'type': user.type,
        'displayName': user.displayName,
        'phoneNum': user.phoneNum,
        'firstName': user.firstName,
        'lastName': user.lastName,
        'dateCreated': FieldValue.serverTimestamp(),
      });
      final userDoc = await _usersRef.doc(user.id).get();
      if (!userDoc.exists) return null;
      return User.fromDocument(userDoc);
    } catch (e) {
      print('error creating user: ${e.toString()}');
      return null;
    }
  }
}
