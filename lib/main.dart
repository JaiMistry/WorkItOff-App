import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

// import './navigation_bar.dart';
// import './pages/intropage.dart';
import 'auth/auth.dart';

void main() {
  // Provider.debugCheckInvalidValueType = null;
  // debugPaintSizeEnabled = true;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [StreamProvider<FirebaseUser>.value(value: FirebaseAuth.instance.onAuthStateChanged)],
      child: MaterialApp(
        // showPerformanceOverlay: true,
        // home: IntroPage(),
        home: CheckSignOnStatus(),
        // home: NavigationBar(),
        theme: ThemeData(textTheme: TextTheme(body1: TextStyle(color: Colors.white))),
      ),
    );
  }
}
