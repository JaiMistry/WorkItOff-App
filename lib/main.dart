import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import './navigation_bar.dart';
import './pages/intropage.dart';

void main() {
  debugPaintSizeEnabled = false;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // home: IntroPage(),
      home: NavigationBar(),
      theme: ThemeData(textTheme: TextTheme(body1: TextStyle(color: Colors.white))),
    );
  }
}
