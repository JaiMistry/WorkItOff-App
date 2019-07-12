import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:provider/provider.dart';
// import 'package:flutter/material.dart';

// Create a user object that is easier to work with
class WorkItOffUser {
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
    Firestore.instance.collection('users').document(id).updateData({'gender': newGender});
  }
}

class DatabaseService {
  final Firestore _db = Firestore.instance;

  /// Get a stream of a single document
  Stream<WorkItOffUser> streamUser(String id) {
    return _db.collection('users').document(id).snapshots().map((snap) => WorkItOffUser.fromFirestore(snap));
  }
}
