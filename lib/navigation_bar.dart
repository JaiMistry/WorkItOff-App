import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import './pages/burnpage.dart';

class NavigationBar extends StatefulWidget {
  @override
  _NavigationBarState createState() => _NavigationBarState();
}

class _NavigationBarState extends State<NavigationBar> {
  int _selectedIndex = 0;
  final List<Widget> _pageOptions = <Widget>[
    BurnPage(),
    Scaffold(body: Center(child: Text("Food Page"))),
    Scaffold(body: Center(child: Text("Workouts Page"))),
    Scaffold(body: Center(child: Text("Profile Page"))),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pageOptions.elementAt(_selectedIndex),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Color(0xff271037),
          splashColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Container(),
              title: Icon(FontAwesomeIcons.fire, color: Colors.white),
            ),
            BottomNavigationBarItem(
              icon: Container(),
              title: Icon(Icons.fastfood, color: Colors.white),
            ),
            BottomNavigationBarItem(
              icon: Container(),
              title: Icon(Icons.directions_bike, color: Colors.white),
            ),
            BottomNavigationBarItem(
              icon: Container(),
              title: Icon(Icons.person, color: Colors.white),
            )
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          unselectedItemColor: Colors.white,
          selectedItemColor: Color(0xff3ADEA7),
        ),
      ),
    );
  }
}
