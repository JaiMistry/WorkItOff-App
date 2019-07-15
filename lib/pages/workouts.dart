import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:workitoff/providers/user_provider.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:workitoff/widgets.dart';

bool _isSliderMoved = false;

// TODO: preserve state of entire page
class WorkoutsPage extends StatefulWidget {
  @override
  _WorkoutsPageState createState() => _WorkoutsPageState();
}

class _WorkoutsPageState extends State<WorkoutsPage>
    with TickerProviderStateMixin {
  AnimationController _animationController;
  TextEditingController _searchController = new TextEditingController();
  bool isButtonDisabled = true;
  String _filter;

  Widget _buildCardList(AsyncSnapshot snapshot) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        DocumentSnapshot workout = snapshot.data.documents[index];
        return _filter == null || _filter == ''
            ? WorkoutCards(snapshot.data.documents[index])
            : workout.documentID.contains(_filter.toLowerCase())
                ? WorkoutCards(workout)
                : Container();
      },
      itemCount: snapshot.data.documents.length,
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

  void _setSearchText() {
    setState(() {
      _filter = _searchController.text;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.removeListener(_setSearchText);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showLogDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Log Workout?'),
          actions: <Widget>[
            FlatButton(
              splashColor: Colors.transparent,
              highlightColor: Colors.grey[200],
              textColor: Colors.black,
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            FlatButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.grey[200],
                textColor: Colors.black,
                child:
                    Text('Log', style: TextStyle(fontWeight: FontWeight.bold)),
                // TODO: check if weight/age has been entered. Redirect to profile page via alert dialog
                // TODO: send logging data to cloud function, redirect to progress page
                onPressed: () => Navigator.of(context).pop()),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [Color(0xff170422), Color(0xff9B22E6)],
          stops: const [0.75, 1],
        ),
      ),
      child: Column(
        children: <Widget>[
          SearchBar(
              hintText: 'Search Workouts',
              controller: _searchController,
              bottomMargin: 6),
          Expanded(
            child: ScrollConfiguration(
              behavior: NoOverscrollBehavior(),
              child: Stack(
                alignment: Alignment.topCenter,
                children: <Widget>[
                  SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        StreamBuilder<QuerySnapshot>(
                          stream: Firestore.instance
                              .collection('workouts')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData | snapshot.hasError) {
                              return Container();
                            }
                            return _buildCardList(snapshot);
                          },
                        ),
                        SizedBox(height: 10.0),
                        AnimatedOpacity(
                          opacity: 1.0,
                          duration: Duration(milliseconds: 200),
                          child: Container(
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
                        ),
                      ],
                    ),
                  ),
                  // TODO: make button fade in realtime when slider is moved
                  Container(
                    alignment: Alignment.bottomCenter,
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
  final DocumentSnapshot data;
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
      height: 316,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: CachedNetworkImage(
                imageUrl: this.widget.data['image_url'],
                placeholder: (context, url) => Container(),
                errorWidget: (context, url, error) =>
                    Container(child: Text('Error Loading image..')),
                fit: BoxFit.cover,
                fadeInCurve: Curves.linear,
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
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0),
                  activeTrackColor: const Color(0xff3ADEA7),
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
        margin: const EdgeInsets.symmetric(horizontal: 10),
      ),
    );
  }
}
