import 'package:flutter/material.dart';

class WorkoutsPage extends StatefulWidget {
  @override
  _WorkoutsPageState createState() => _WorkoutsPageState();
}

class _WorkoutsPageState extends State<WorkoutsPage> {
  double _sliderValue = 0.0;

  void _setValue(double value) {
    setState(() {
      _sliderValue = value;
    });
  }

  final List<String> cardList = [
    'assets/cards/running.png',
    'assets/cards/hiking.png',
    'assets/cards/aerobics.png',
    'assets/cards/swimming.png',
  ];

  Widget _buildWorkoutCard(BuildContext context, int index) {
    return Container(
      height: 250,
      child: Column(
        children: <Widget>[
          Card(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.asset(
                cardList[index],
                fit: BoxFit.cover,
              ),
            ),
            elevation: 5.0,
            margin: EdgeInsets.all(15.0),
          ),
        ],
      ),
    );
  }

  Widget _buildCardList() {
    return ListView.builder(
        itemCount: cardList.length, itemBuilder: _buildWorkoutCard);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints.expand(),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xff170422), Color(0xff9B22E6)],
          stops: [0.75, 1],
        ),
      ),
      child: _buildCardList(),
    );
  }
}
