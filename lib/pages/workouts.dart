// import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:workitoff/navigation_bar.dart';
import 'package:workitoff/providers/navbar_provider.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:workitoff/providers/user_provider.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:workitoff/widgets.dart';

final BottomNavigationBar navBar = navBarGlobalKey.currentWidget;

class WorkoutsPage extends StatefulWidget {
  @override
  _WorkoutsPageState createState() => _WorkoutsPageState();
}

class _WorkoutsPageState extends State<WorkoutsPage> with TickerProviderStateMixin {
  AnimationController _animationController;
  TextEditingController _searchController = new TextEditingController();
  String _filter;
  bool _isSliderMoved = false;
  Map<String, double> workoutsMap = {};

  void _updateWorkoutsList(String workoutName, double sliderValue) {
    workoutsMap[workoutName] = sliderValue;
  }

  Widget _buildCardList(AsyncSnapshot snapshot) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        DocumentSnapshot workout = snapshot.data.documents[index];
        return _filter == null || _filter == ''
            ? WorkoutCards(snapshot.data.documents[index], _sliderMoved, _isSliderMoved, _updateWorkoutsList)
            : workout.documentID.contains(_filter.toLowerCase())
                ? WorkoutCards(workout, _sliderMoved, _isSliderMoved, _updateWorkoutsList)
                : Container();
      },
      itemCount: snapshot.data.documents.length,
    );
  }

  void _sliderMoved(bool isSliderMoved) {
    if (isSliderMoved != _isSliderMoved) {
      setState(() {
        _isSliderMoved = isSliderMoved;
        if (_isSliderMoved == true) {
          _animationController.forward();
        } else {
          _animationController.reverse();
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _filter = _searchController.text;
      });
    });
    _animationController = AnimationController(duration: const Duration(milliseconds: 350), vsync: this);
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

  Future<void> _callCloudFucntion(Map workoutsMap) async {
    String userID = Provider.of<WorkItOffUser>(context).getID();

    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'addWorkouts',
    );
    
    try {
      dynamic resp = await callable.call(<String, dynamic>{"userID": userID, "workoutsMap": workoutsMap});
    } catch (e) {
      debugPrint('An error has occured');
    }
  }

  Future<void> _showLogDialog() async {
    WorkItOffUser user = Provider.of<WorkItOffUser>(context);
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
                child: Text('Log', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  if (user.getAge() == null || user.getAge().toString().isEmpty) {
                    Navigator.of(context).pop();
                    _showMissingDataDialog('Age');
                    return;
                  }
                  if (user.getGender() == null || user.getGender().isEmpty) {
                    Navigator.of(context).pop();
                    _showMissingDataDialog('Gender');
                    return;
                  }
                  // TODO: Change so the user can sucessfully reset
                  if (user.getWeight() == null || user.getWeight().toString().isEmpty) {
                    Navigator.of(context).pop();
                    _showMissingDataDialog('Weight');
                    return;
                  }
                  // TODO: Send workouts to cloud function. These are placeholder calories
                  // print(workoutsMap); // Contains the values that will be based to the cloud function
                  // user.calsBurned = 500; // TODO
                  _callCloudFucntion(workoutsMap);

                  _sliderMoved(false); // Reset the slider
                  Navigator.of(context).pop(); // Pop the alertDialog
                  // Provider.of<ProgressProvider>(context).showProgress = true;
                  navBar.onTap(0); // Redirect to burn page
                }),
          ],
        );
      },
    );
  }

  Future<void> _showMissingDataDialog(String data) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('You have not set your $data yet.'),
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
              child: Text('Set $data', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop();
                navBar.onTap(3);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: getBasicGradient(),
      child: Column(
        children: <Widget>[
          SearchBar(hintText: 'Search Workouts', controller: _searchController, bottomMargin: 6),
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
                          stream: Firestore.instance.collection('workouts').snapshots(),
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
                                  style: TextStyle(color: Colors.white, fontSize: 10.0),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 75),
                      ],
                    ),
                  ),
                  Consumer<NavBarProvider>(builder: (ctx, navbar, child) {
                    if (navbar.currentPage == 2 && _isSliderMoved) {
                      _animationController.forward();
                    } else {
                      _animationController.reverse();
                    }
                    return Container(
                      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
                      alignment: Alignment.bottomCenter,
                      child: FadeTransition(
                        opacity: CurvedAnimation(parent: _animationController, curve: Curves.linear),
                        child: Container(
                          width: double.infinity,
                          child: FlatButton(
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            color: Color(0xff4ff7d3),
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            child: Text("Enter Workouts", style: TextStyle(fontSize: 18.0)),
                            onPressed: () {
                              return _isSliderMoved ? _showLogDialog() : null;
                            },
                          ),
                        ),
                      ),
                    );
                  }),
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
  final Function sliderMoved;
  final bool isSliderMoved;
  final Function updateWorkoutsList;
  WorkoutCards(this.data, this.sliderMoved, this.isSliderMoved, this.updateWorkoutsList) : super();

  @override
  State<StatefulWidget> createState() {
    return _WorkoutCardsState();
  }
}

class _WorkoutCardsState extends State<WorkoutCards> {
  double _sliderValue = 0.0;

  void _setValue(double value) {
    widget.updateWorkoutsList(widget.data.documentID, value);
    setState(() {
      _sliderValue = value;
      widget.sliderMoved(true);
    });
  }

  @override
  void didUpdateWidget(WorkoutCards oldWidget) {
    if (widget.isSliderMoved == false && _sliderValue > 0.0) {
      setState(() {
        _sliderValue = 0.0;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.45,
      child: Column(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: CachedNetworkImage(
              imageUrl: widget.data['image_url'],
              placeholder: (context, url) => Container(),
              errorWidget: (context, url, error) => Container(child: Text('Error Loading image..')),
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
      margin: const EdgeInsets.symmetric(horizontal: 10),
    );
  }
}
