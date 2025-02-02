import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
// import 'package:workitoff/providers/progress_provider.dart';

// import './navigation_bar.dart';
import 'package:workitoff/providers/navbar_provider.dart';
// import './pages/intropage.dart';
import 'auth/auth.dart';

FirebaseAnalytics analytics = FirebaseAnalytics();

void main() {
  // Provider.debugCheckInvalidValueType = null;
  // debugPaintSizeEnabled = true;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // FirebaseAuth.instance.signOut();  //Run this if the app crashes. I deleted all the users in firestore. This will force a new one to be created.
    return MultiProvider(
      providers: [
        StreamProvider<FirebaseUser>.value(value: FirebaseAuth.instance.onAuthStateChanged),
        ChangeNotifierProvider<NavBarProvider>.value(value: NavBarProvider()),
        // ChangeNotifierProvider<ProgressProvider>.value(value: ProgressProvider())
      ],
      child: MaterialApp(
        navigatorObservers: [FirebaseAnalyticsObserver(analytics: analytics)],
        // showPerformanceOverlay: true,
        // home: IntroPage(),
        home: CheckSignOnStatus(),
        // home: NavigationBar(),
        theme: ThemeData(textTheme: TextTheme(body1: TextStyle(color: Colors.white))),
      ),
    );
  }
}
