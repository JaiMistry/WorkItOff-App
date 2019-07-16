import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:workitoff/pages/profilepage.dart';
import 'package:workitoff/pages/burnpage.dart';
import 'package:workitoff/pages/workouts.dart';
import 'package:workitoff/pages/food.dart';
import 'package:workitoff/providers/user_provider.dart';
import 'package:workitoff/providers/navbar_provider.dart';

class NavigationBar extends StatefulWidget {
  @override
  _NavigationBarState createState() => _NavigationBarState();
}

class _NavigationBarState extends State<NavigationBar> {
  int _selectedIndex = 0;
  final List<Widget> _pageOptions = <Widget>[
    BurnPage(),
    FoodPage(),
    WorkoutsPage(),
    ProfilePage(),
    // FoodItemPage()  // TODO: Maybe make this a global page and pass parameters??
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      Provider.of<NavBarProvider>(context).currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    String userID =
        Provider.of<FirebaseUser>(context, listen: false) != null ? Provider.of<FirebaseUser>(context).uid : 'null';

    return MultiProvider(
      providers: [StreamProvider<WorkItOffUser>.value(value: DatabaseService().streamUser(userID))],
      child: Scaffold(
        body: IndexedStack(
          children: _pageOptions,
          index: Provider.of<NavBarProvider>(context).currentPage,
        ),
        bottomNavigationBar: BottomNavBar(),
      ),
    );
  }
}

class BottomNavBar extends StatefulWidget {
  BottomNavBar({Key key}) : super(key: key);

  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  @override
  void initState() {
    _selectedIndex = Provider.of<NavBarProvider>(context, listen: false).currentPage;

    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      Provider.of<NavBarProvider>(context, listen: false).currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: const Color(0xff271037),
        splashColor: Colors.transparent,
      ),
      child: BottomNavigationBar(
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
    );
  }
}
