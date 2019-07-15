// import 'dart:io';

import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'package:workitoff/navigation_bar.dart';
import 'package:workitoff/widgets.dart';
import 'package:workitoff/pages/intropage.dart';

final FirebaseAuth _firebaseAuth = FirebaseAuth.instance; // Create firebase_auth instance
final Firestore _firestore = Firestore.instance; // Create firestore instance

void signInAnonymously({
  @required BuildContext context,
  @required int weight,
  @required int age,
  @required String gender,
}) async {
  final FirebaseUser user = await _firebaseAuth.signInAnonymously();

  final FirebaseUser currentUser = await _firebaseAuth.currentUser();
  assert(user.uid == currentUser.uid);
  String _userID = user.uid;

  if (user != null) {
    debugPrint(_userID + " has sucessfully signed in!");

    //Overwrites entire document
    _addNewUser(_userID, gender, age, weight);

  } else {
    showDefualtFlushBar(context: context, text: 'Unable to sign in.');
  }
}

Future<void> _addNewUser(String userID, String gender, int age, int weight) async {
  return await _firestore.collection('users').document(userID).setData(
      {'age': age, 'weight': weight, 'gender': gender, 'date_joined': Timestamp.now(), 'last_login': Timestamp.now()});
}

Future<void> updateProfile(String userID, String gender, int age, int weight) async {
  if (gender == '' || gender == null) {
    return _firestore.collection('users').document(userID).updateData({'age': age, 'weight': weight});
  }
  return _firestore.collection('users').document(userID).updateData({'age': age, 'weight': weight, 'gender': gender});
}

Future<void> updateLastSignedIn(String userID) async {
  return _firestore.collection('users').document(userID).updateData({'last_login': Timestamp.now()});
}

Future<FirebaseUser> getCurrentFireBaseUser() async {
  return await _firebaseAuth.currentUser();
}

Future<String> getCurrentFireBaseUserId() async {
  FirebaseUser user = await _firebaseAuth.currentUser();
  return user.uid;
}


// * Sign on status

enum AuthStatus {
  notSignedin,
  signedIn,
}

class CheckSignOnStatus extends StatefulWidget {
  CheckSignOnStatus({Key key}) : super(key: key);

  _CheckSignOnStatusState createState() => _CheckSignOnStatusState();
}

class _CheckSignOnStatusState extends State<CheckSignOnStatus> {
  @override
  Widget build(BuildContext context) {
    FirebaseUser user = Provider.of<FirebaseUser>(context);
    AuthStatus _authStatus = user != null ? AuthStatus.signedIn : AuthStatus.notSignedin;
    print('Auth Status = $_authStatus');

    return _authStatus == AuthStatus.signedIn ? NavigationBar() : IntroPage();
  }
}
