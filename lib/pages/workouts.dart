import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

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
    'assets/cards/yoga.png',
    'assets/cards/weight_lifting.png',
    'assets/cards/stairs.png',
  ];

  Widget _buildWorkoutCard(BuildContext context, int index) {
    return Container(
      height: 305,
      child: Column(
        children: <Widget>[
          Card(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.asset(
                    cardList[index],
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Text(
                    '${_sliderValue.round()}' + ' MINUTES',
                    style: TextStyle(color: Colors.white, fontSize: 15.0),
                  ),
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                      thumbColor: Colors.white,
                      thumbShape:
                          RoundSliderThumbShape(enabledThumbRadius: 10.0),
                      activeTrackColor: Color(0xff3ADEA7),
                      inactiveTrackColor: Colors.grey,
                      overlayColor: Colors.transparent,
                      trackHeight: 1.0),
                  child: Slider(
                    value: _sliderValue,
                    onChanged: _setValue,
                    min: 0.0,
                    max: 150.0,
                    divisions: 30,
                  ),
                ),
              ],
            ),
            color: Colors.transparent,
            elevation: 0.0,
            margin: EdgeInsets.all(10.0),
          ),
        ],
      ),
    );
  }

  Widget _buildCardList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: _buildWorkoutCard,
      itemCount: cardList.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // constraints: BoxConstraints.expand(),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xff170422), Color(0xff9B22E6)],
          stops: [0.75, 1],
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _buildCardList(),
            SizedBox(height: 20.0),
            Container(
              padding: EdgeInsets.only(bottom: 90.0),
              child: Column(
                children: <Widget>[
                  Text(
                    'We are always adding new workouts!',
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    'Calories burned are calculated from your weight and our algorithm.',
                    style: TextStyle(color: Colors.white, fontSize: 10.0),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
