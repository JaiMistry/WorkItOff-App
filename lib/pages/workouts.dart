import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

bool _isSliderMoved = false;

class WorkoutsPage extends StatefulWidget {
  @override
  _WorkoutsPageState createState() => _WorkoutsPageState();
}

class _WorkoutsPageState extends State<WorkoutsPage>
    with TickerProviderStateMixin {
  AnimationController _animationController;
  TextEditingController _searchController = new TextEditingController();
  bool isButtonDisabled = false;

  String _filter;
  RegExp pattern =
      new RegExp(r'[^\/][\w]+(?=\.)', caseSensitive: false, multiLine: false);

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
      itemBuilder: (BuildContext context, int index) {
        return _filter == null || _filter == ''
            ? WorkoutCards(cardList[index])
            : pattern
                    .stringMatch(cardList[index])
                    .contains(_filter.toLowerCase())
                ? WorkoutCards(cardList[index])
                : Container();
      },
      itemCount: cardList.length,
    );
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _filter = _searchController.text;
      });
    });
    if (_isSliderMoved) {
      isButtonDisabled = false;
      _animationController = AnimationController(
          duration: const Duration(milliseconds: 350), vsync: this);
      _animationController.forward();
    } else {
      isButtonDisabled = true;
      _animationController = AnimationController(vsync: this);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showLogDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Log Workout?'),
          actions: <Widget>[
            FlatButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.grey[200],
                textColor: Colors.black,
                child: Text('Cancel'),
                onPressed: () => Navigator.of(context).pop()),
            FlatButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.grey[200],
                textColor: Colors.black,
                child: Text(
                  'Log',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () => Navigator.of(context).pop()),
          ],
        );
      },
    );
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
          SearchBar(hintText: 'Search Workouts', controller: _searchController, bottomMargin: 6),
          Expanded(
            child: ScrollConfiguration(
              behavior: NoOverscrollBehavior(),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        _buildCardList(),
                        SizedBox(height: 10.0),
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
                                style: TextStyle(
                                    color: Colors.white, fontSize: 10.0),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    child: FadeTransition(
                      opacity: CurvedAnimation(
                          parent: _animationController, curve: Curves.linear),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: FlatButton(
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          color: Color(0xff4ff7d3),
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          child: Text("Enter Workouts",
                              style: TextStyle(fontSize: 18.0)),
                          onPressed: () {
                            return isButtonDisabled ? null : _showLogDialog();
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// * Each card needs to have its own individual state
class WorkoutCards extends StatefulWidget {
  final String data;
  WorkoutCards(this.data) : super();

  @override
  State<StatefulWidget> createState() {
    return _WorkoutCardsState();
  }
}

class _WorkoutCardsState extends State<WorkoutCards> {
  double _sliderValue = 0.0;

  void _setValue(double value) {
    setState(() {
      _sliderValue = value;
      _isSliderMoved = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 306,
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
