// import 'dart:io';

import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:workitoff/navigation_bar.dart';
import 'package:workitoff/widgets.dart';
import 'package:workitoff/pages/intropage.dart';

final FirebaseAuth _firebaseAuth = FirebaseAuth.instance; // Create firebase_auth instance
final Firestore _firestore = Firestore.instance; // Create firestore instance

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
    _addNewUser(_userID, gender, age, weight);
    _saveNewUser(_userID);

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => NavigationBar()));
  } else {
    showDefualtFlushBar(context: context, text: 'Unable to sign in.');
  }
}

Future<void> _addNewUser(String userID, String gender, int age, int weight) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setInt('age', age);
  prefs.setInt('weight', weight);
  prefs.setString('gender', gender);

  return await _firestore.collection('users').document(userID).setData(
      {'age': age, 'weight': weight, 'gender': gender, 'date_joined': Timestamp.now(), 'last_login': Timestamp.now()});
}

Future<bool> _saveNewUser(String userId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return await prefs.setString('uid', userId);
}

Future<String> getUserIDFromPrefs() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('uid');
}

Future<void> updateProfile(String userID, String gender, int age, int weight) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setInt('age', age);
  prefs.setInt('weight', weight);
  prefs.setString('gender', gender);

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

enum AuthStatus {
  notSignedin,
  signedIn,
}

class CheckSignOnStatus extends StatefulWidget {
  CheckSignOnStatus({Key key}) : super(key: key);

  _CheckSignOnStatusState createState() => _CheckSignOnStatusState();
}

class _CheckSignOnStatusState extends State<CheckSignOnStatus> {
  AuthStatus _authStatus = AuthStatus.notSignedin;

  @override
  void initState() {
    super.initState();

    getCurrentFireBaseUser().then((FirebaseUser user) {
      setState(() {
        if (user.uid != null) {
          _authStatus = AuthStatus.signedIn;
          updateLastSignedIn(user.uid);
        } else {
          _authStatus = AuthStatus.notSignedin;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // If the user is signed in
    return _authStatus == AuthStatus.signedIn ? NavigationBar() : IntroPage();
  }
}
