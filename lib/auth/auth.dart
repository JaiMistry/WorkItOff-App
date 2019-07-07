// import 'dart:io';

import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:workitoff/navigation_bar.dart';
import 'package:workitoff/widgets.dart';

final FirebaseAuth _firebaseAuth = FirebaseAuth.instance; // Create firebase_auth instance
final Firestore _firestore = Firestore.instance;  // Create firestore instance


void signInAnonymously(
    {@required BuildContext context, @required int weight, @required int age, @required String gender}) async {
  final FirebaseUser user = await _firebaseAuth.signInAnonymously();
  // assert(user != null);
  // assert(user.isAnonymous);
  // assert(!user.isEmailVerified);
  // assert(await user.getIdToken() != null);
  // if (Platform.isIOS) {
  //   // Anonymous auth doesn't show up as a provider on iOS
  //   // assert(user.providerData.isEmpty);
  // } else if (Platform.isAndroid) {
  //   // Anonymous auth does show up as a provider on Android
  //   assert(user.providerData.length == 1);
  //   assert(user.providerData[0].providerId == 'firebase');
  //   // assert(user.providerData[0].uid != null);
  //   // assert(user.providerData[0].displayName == null);
  //   // assert(user.providerData[0].photoUrl == null);
  //   // assert(user.providerData[0].email == null);
  // }

  final FirebaseUser currentUser = await _firebaseAuth.currentUser();
  assert(user.uid == currentUser.uid);
  String _userID = user.uid;

  if (user != null) {
    debugPrint(_userID + " has sucessfully signed in!");

    showDefualtFlushBar(context: context, text: 'Successuyfully signed in!');

    //Overwrites entire document
    addUser(_userID, gender, age, weight);

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => NavigationBar()));
  } else {
    showDefualtFlushBar(context: context, text: 'Unable to sign in.');
  }
}

void addUser(String userID, String gender, int age, int weight) async {
  _firestore.collection('users').document(userID).setData({'age': age, 'weight': weight, 'gender': gender});
}
