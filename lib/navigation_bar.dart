import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:keyboard_avoider/keyboard_avoider.dart';

import 'package:workitoff/pages/profilepage.dart';
import 'package:workitoff/pages/workouts.dart';
import 'package:workitoff/pages/food/food_home.dart';
import 'package:workitoff/providers/navbar_provider.dart';
import 'package:workitoff/providers/user_provider.dart';
import 'package:workitoff/pages/home/home_decider.dart';

GlobalKey navBarGlobalKey = GlobalKey(debugLabel: 'bottomAppBar');

class NavigationBar extends StatefulWidget {
  @override
  _NavigationBarState createState() => _NavigationBarState();
}

class _NavigationBarState extends State<NavigationBar> {
  int _selectedIndex = 0;
  List<Widget> _pageOptions = <Widget>[
    HomeDecider(),
    FoodPage(),
    WorkoutsPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      Provider.of<NavBarProvider>(context, listen: false).currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    String userID = Provider.of<FirebaseUser>(context, listen: false)?.uid ?? 'null';
    return MultiProvider(
      providers: [StreamProvider<WorkItOffUser>.value(value: DatabaseService().streamUser(userID))],
      child: Scaffold(
        // resizeToAvoidBottomInset: false, //Changes the way the foodGrid reacts to softkeyboard
        extendBody: true, // Enables transparent BG
        body: IndexedStack(
          children: _pageOptions,
          index: _selectedIndex,
        ),
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: const Color(0xff271037).withOpacity(0.90), //Navbar transparency
            splashColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            key: navBarGlobalKey,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            unselectedItemColor: Colors.white,
            selectedItemColor: const Color(0xff3ADEA7),
            type: BottomNavigationBarType.fixed,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Container(),
                title: const Icon(FontAwesomeIcons.fire, color: Colors.white),
              ),
              BottomNavigationBarItem(
                icon: Container(),
                title: const Icon(Icons.fastfood, color: Colors.white),
              ),
              BottomNavigationBarItem(
                icon: Container(),
                title: const Icon(Icons.directions_bike, color: Colors.white),
              ),
              BottomNavigationBarItem(
                icon: Container(),
                title: const Icon(Icons.person, color: Colors.white),
              )
            ],
          ),
        ),
      ),
    );
  }
}
