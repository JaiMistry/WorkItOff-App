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
  final int age;
  final int weight;
  final int calsBurned;
  final int calsAdded;

  WorkItOffUser({
    this.id,
    this.gender,
    this.age,
    this.weight,
    this.calsAdded,
    this.calsBurned,
  });

  // Injest the firestore document snapshot and return a WorkItOffUser object
  factory WorkItOffUser.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data;
    return WorkItOffUser(
      id: doc.documentID,
      gender: data['gender'],
      age: data['age'] == null ? 0 : data['age'],
      weight: data['weight'] == null ? 0 : data['weight'],
      calsAdded: data['cals_added'] == null ? 0 : data['cals_added'],
      calsBurned: data['cals_burned'] == null ? 0 : data['cals_burned'],
    );
  }

  String getID() => this.id;
  String getGender() => this.gender;
  int getAge() => this.age;
  int getWeight() => this.weight;
  int getCalsAdded() => this.calsAdded;
  int getCalsBurned() => this.calsBurned;

  set gender(String newGender) {
    _firestore.collection('users').document(id).updateData({'gender': newGender});
  }

  set age(int newAge) {
    _firestore.collection('users').document(id).updateData({'age': newAge});
  }

  set weight(int newWeight) {
    _firestore.collection('users').document(id).updateData({'age': newWeight});
  }

  set calsAdded(int newCalsAdded) {
    // This is the set the value. Not increment
    _firestore.collection('users').document(id).updateData({'cals_added': newCalsAdded});
  }

  set calsBurned(int newCalsBurned) {
    // This is the set the value. Not increment
    _firestore.collection('users').document(id).updateData({'cals_burned': newCalsBurned});
  }
  

  Future<void> updateProfile({
    String gender,
    int age,
    int weight,
    int calsBurned,
    int calsAdded,
  }) async {
    Map<String, dynamic> userMap = {};
    if (gender != null && gender.isNotEmpty) {
      userMap.putIfAbsent('gender', () => gender);
    }
    if (age != null) {
      userMap.putIfAbsent('age', () => age);
    }
    if (weight != null) {
      userMap.putIfAbsent('weight', () => weight);
    }
    if (calsAdded != null) {
      userMap.putIfAbsent('cals_added', () => calsAdded);
    }
    if (calsBurned != null) {
      userMap.putIfAbsent('cals_burned', () => calsBurned);
    }

    print(userMap);
    return _firestore.collection('users').document(id).updateData(userMap);
  }
}

class DatabaseService {
  final Firestore _db = Firestore.instance;

  /// Get a stream of a single document
  Stream<WorkItOffUser> streamUser(String id) {
    return _db.collection('users').document(id).snapshots().map((snap) => WorkItOffUser.fromFirestore(snap));
  }
}
