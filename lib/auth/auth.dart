import 'dart:io';

import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:workitoff/widgets.dart';

final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

class AuthPage extends StatefulWidget {
  AuthPage({Key key}) : super(key: key);

  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _success;
  String _userID;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff170422),
      body: Container(
        padding: EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              alignment: Alignment.center,
              child: RaisedButton(
                onPressed: () async {
                  _register();
                },
                child: Text('Sign Up Anonymosly'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    super.dispose();
  }

  void _register() async {
    final FirebaseUser user = await _firebaseAuth.signInAnonymously();
    assert(user != null);
    assert(user.isAnonymous);
    assert(!user.isEmailVerified);
    assert(await user.getIdToken() != null);
    if (Platform.isIOS) {
      // Anonymous auth doesn't show up as a provider on iOS
      // assert(user.providerData.isEmpty);
    } else if (Platform.isAndroid) {
      // Anonymous auth does show up as a provider on Android
      assert(user.providerData.length == 1);
      assert(user.providerData[0].providerId == 'firebase');
      // assert(user.providerData[0].uid != null);
      // assert(user.providerData[0].displayName == null);
      // assert(user.providerData[0].photoUrl == null);
      // assert(user.providerData[0].email == null);
    }

    final FirebaseUser currentUser = await _firebaseAuth.currentUser();
    assert(user.uid == currentUser.uid);
    setState(() {
      if (user != null) {
        bool _success = true;
        String _userID = user.uid;

        showDefualtFlushBar(context: context, text: 'Successuyfully signed in!');
      } else {
        _success = false;
        showDefualtFlushBar(context: context, text: 'Unable to sign in.');
      }
    });
  }
}
