// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:workitoff/navigation_bar.dart';
import 'package:workitoff/widgets.dart';

final BottomNavigationBar navBar = navBarGlobalKey.currentWidget;

class BurnPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints.expand(),
      decoration: getBasicGradient(),
      child: Column(
        children: <Widget>[
          Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: Image.asset('assets/text_logo.png', width: 80),
              ),
              const SizedBox(height: 50),
              Image.asset('assets/logo_transparent.png', height: 300),
              const SizedBox(height: 50),
              Container(
                child: Column(
                  children: <Widget>[
                    const Text('Enjoy something', style: const TextStyle(color: Colors.white, fontSize: 25.0)),
                    const Text('delicious... come back and', style: TextStyle(color: Colors.white, fontSize: 25.0)),
                    const Text('Work It Off!', style: const TextStyle(color: Color(0xff3ADEA7), fontSize: 25.0)),
                    SizedBox(
                      width: 60.0,
                      child: OutlineButton(
                        child: const Text('Go', style: TextStyle(color: Colors.white)),
                        onPressed: () {
                          // Scaffold.of(context).showSnackBar(SnackBar(content: Text('You have been signed out!')));
                          // final auth = FirebaseAuth.instance;
                          // auth.signOut();
                          navBar.onTap(1);
                        },
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                        borderSide: const BorderSide(color: Color(0xff17e3f1)),
                        highlightColor: const Color(0xff17e3f1),
                        highlightedBorderColor: const Color(0xff17e3f1),
                        splashColor: Colors.transparent,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
