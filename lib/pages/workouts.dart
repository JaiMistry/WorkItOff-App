import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

final List<String> cardList = [
  'assets/cards/running.png',
  'assets/cards/yoga.png',
  'assets/cards/weight_lifting.png',
  'assets/cards/stairs.png',
];

Widget _buildCardList() {
  return ListView.builder(
    shrinkWrap: true,
    physics: NeverScrollableScrollPhysics(),
    itemBuilder: (BuildContext context, int index) =>
        MyWorkoutCards(cardList[index]),
    itemCount: cardList.length,
  );
}

class WorkoutsPage extends StatefulWidget {
  @override
  _WorkoutsPageState createState() => _WorkoutsPageState();
}

class _WorkoutsPageState extends State<WorkoutsPage>
    with SingleTickerProviderStateMixin {
  bool _isSliderMoved = true;
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    if (_isSliderMoved) {
      _controller = AnimationController(
          duration: const Duration(milliseconds: 350), vsync: this);
      _controller.forward();
    } else {
      _controller = AnimationController(vsync: this);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xff170422), Color(0xff9B22E6)],
          stops: [0.75, 1],
        ),
      ),
      child: Column(
        children: <Widget>[
          // TODO: add Searchbar
          Expanded(
            child: ScrollConfiguration(
              behavior: NoOverscrollBehavior(),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    _buildCardList(),
                    SizedBox(height: 20.0),
                    Container(
                      padding: EdgeInsets.only(bottom: 50.0),
                      child: Column(
                        children: <Widget>[
                          Text(
                            'We are always adding new workouts!',
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(height: 10.0),
                          Text(
                            'Calories burned are calculated from your weight and our algorithm.',
                            style:
                                TextStyle(color: Colors.white, fontSize: 10.0),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          FadeTransition(
            opacity: CurvedAnimation(parent: _controller, curve: Curves.linear),
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: FlatButton(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                color: Color(0xff4ff7d3),
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: Text("Enter Workouts", style: TextStyle(fontSize: 18.0)),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// * Each card needs to have its own individual state
class MyWorkoutCards extends StatefulWidget {
  final String data;
  MyWorkoutCards(this.data) : super();

  @override
  State<StatefulWidget> createState() {
    return _MyWorkoutCardsState();
  }
}

class _MyWorkoutCardsState extends State<MyWorkoutCards> {
  double _sliderValue;

  @override
  void initState() {
    super.initState();
    _sliderValue = 0.0;
  }

  void _setValue(double value) {
    setState(() {
      _sliderValue = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 305,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.asset(
                this.widget.data,
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
                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10.0),
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
    );
  }
}

// * Prevent glow effect from overscrolling
class NoOverscrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
