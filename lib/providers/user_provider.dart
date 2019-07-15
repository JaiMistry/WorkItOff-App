import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
// import 'package:provider/provider.dart';
// import 'package:flutter/material.dart';

// Create a user object that is easier to work with
class WorkItOffUser {
  final Firestore _firestore = Firestore.instance; // Create firestore instance
  final String id;
  final String gender;
  final String age;
  final String weight;

  WorkItOffUser({this.id, this.gender, this.age, this.weight});

  // Injest the firestore document snapshot and return a WorkItOffUser object
  factory WorkItOffUser.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data;
    return WorkItOffUser(
      id: doc.documentID,
      gender: data['gender'],
      age: data['age'].toString(),
      weight: data['weight'].toString(),
    );
  }

  set gender(String newGender) {
    _firestore.collection('users').document(id).updateData({'gender': newGender});
  }

  set age(String newAge) {
    _firestore.collection('users').document(id).updateData({'age': newAge});
  }

  set weight(String newWeight) {
    _firestore.collection('users').document(id).updateData({'age': newWeight});
  }

  Future<void> updateProfile({@required String userID, String gender, int age, int weight}) async {
    Map<String, dynamic> userMap;
    if(gender != null || gender != ''){
      userMap.putIfAbsent('gender', () => gender);
    }
    if(age != null || age.toString() != ''){
      userMap.putIfAbsent('age', () => age);
    }
    if(weight != null || weight.toString() != ''){
      userMap.putIfAbsent('weight', () => weight);
    }
    return _firestore.collection('users').document(userID).updateData(userMap);
  }
}

class DatabaseService {
  final Firestore _db = Firestore.instance;

  /// Get a stream of a single document
  Stream<WorkItOffUser> streamUser(String id) {
    return _db.collection('users').document(id).snapshots().map((snap) => WorkItOffUser.fromFirestore(snap));
  }
}
