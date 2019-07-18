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
  // TODO: There is no exception handling when there is a network timeout!
  final FirebaseUser user = await _firebaseAuth.signInAnonymously().timeout(Duration(seconds: 2), onTimeout: () {
    showDefualtFlushBar(context: context, text: 'Unable to sign in.');
    return;
  });
  if (user != null) {
    //Overwrites entire document
    await _addNewUser(user.uid, gender, age, weight).catchError((e) {
      showDefualtFlushBar(context: context, text: 'Unable to sign in.');
    });
    debugPrint(user.uid + " has sucessfully signed in!");
  } else {
    showDefualtFlushBar(context: context, text: 'Unable to sign in.');
  }
}

Future<void> _addNewUser(String userID, String gender, int age, int weight) async {
  return _firestore.collection('users').document(userID).setData(
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
  return _firebaseAuth.currentUser();
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
