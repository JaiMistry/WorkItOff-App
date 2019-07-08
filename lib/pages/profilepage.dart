import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:workitoff/widgets.dart';
import 'package:workitoff/auth/auth.dart';

final Firestore _firestore = Firestore.instance; // Create firestore instance

bool _isNumeric(String str) {
  if (str == null) {
    return false;
  }
  return double.tryParse(str) != null;
}

class StandardTextInputField extends StatefulWidget {
  final String label;
  final String failedValidateText;
  final String initialVal;
  final Function updateInputMap;

  StandardTextInputField(
      {Key key, this.label: '', this.failedValidateText: '', this.initialVal, @required this.updateInputMap})
      : super(key: key);

  _StandardTextInputFieldState createState() => _StandardTextInputFieldState();
}

class _StandardTextInputFieldState extends State<StandardTextInputField> {
  FocusNode _focusNode;
  Color _labelColor = Colors.grey;
  TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();

    _focusNode.addListener(() {
      setState(() {
        _focusNode.hasFocus ? _labelColor = Color(0xff4ff7d3) : _labelColor = Colors.grey;
      });
    });
  }

  void setFocus() {
    FocusScope.of(context).requestFocus(_focusNode);
  }

  @override
  void dispose() {
    _focusNode.dispose(); // Clean up the focus node when the Form is disposed.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(bottom: 2.0),
            child: Text(widget.label, style: TextStyle(color: _labelColor)),
          ),
          TextFormField(
            controller: _controller,
            focusNode: _focusNode,
            initialValue: widget.initialVal,
            validator: (string) {
              if (string.isEmpty || !_isNumeric(string)) {
                return widget.failedValidateText;
              }
              return null;
            },
            inputFormatters: [LengthLimitingTextInputFormatter(3)],
            keyboardType: TextInputType.number,
            // autovalidate: true,
            cursorColor: Color(0xff4ff7d3),
            decoration: InputDecoration(
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(style: BorderStyle.none),
                borderRadius: BorderRadius.all(Radius.zero),
              ),
              // labelText: widget.label,
              filled: true,
              fillColor: Color(0xffd1d1d1).withOpacity(0.15),
              labelStyle: TextStyle(color: Colors.grey),
              contentPadding: EdgeInsets.all(8.0),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.zero),
                borderSide: BorderSide(style: BorderStyle.none),
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.zero)),
            ),
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class GenderRadio extends StatefulWidget {
  final String initialVal;
  GenderRadio({Key key, this.initialVal: ''}) : super(key: key);

  _GenderRadioState createState() => _GenderRadioState();
}

class _GenderRadioState extends State<GenderRadio> {
  int _selected = 0;
  Map<int, Color> _genderMapping = {0: Colors.white, 1: Colors.white}; // Handles whether item is selected or not

  @override
  void initState() {
    if (widget.initialVal == 'female') {
      onRadioChanged(1);
    }
    super.initState();
  }

  void onRadioChanged(int value) {
    setState(() {
      _selected = value;
      _genderMapping[value] = Color(0xff4ff7d3); // Change the slected item color
      value == 0 ? _genderMapping[1] = Colors.white : _genderMapping[0] = Colors.white; // Unslected item
    });
  }

  List<Widget> makeRadios() {
    List<String> twoGenders = ['Male', 'Female'];
    List<Widget> list = List<Widget>();

    for (int i = 0; i < twoGenders.length; i++) {
      list.add(Material(
        color: Colors.transparent,
        child: Theme(
          data: ThemeData.dark(),
          child: RadioListTile(
            value: i,
            controlAffinity: ListTileControlAffinity.trailing,
            dense: true,
            title: Text(twoGenders.elementAt(i), style: TextStyle(fontSize: 14.0, color: _genderMapping[i])),
            activeColor: Color(0xff4ff7d3),
            groupValue: _selected,
            onChanged: (int value) {
              onRadioChanged(value);
            },
          ),
        ),
      ));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: makeRadios(),
      ),
    );
  }
}

class BuildProfileForm extends StatefulWidget {
  final Function updateInputMap;
  final GlobalKey<FormState> formKey;
  BuildProfileForm({Key key, @required this.formKey, @required this.updateInputMap}) : super(key: key);

  _BuildProfileFormState createState() => _BuildProfileFormState();
}

class _BuildProfileFormState extends State<BuildProfileForm> {
  String _userID = 'null';

  @override
  void initState() {
    super.initState();
    _getUserID();
  }

  _getUserID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userID = (prefs.getString('uid') ?? 'null');
      // print(_userID + ' is the UID first!');
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('users').document(_userID).snapshots(),
      builder: (context, snapshot) {
        String _age = '';
        String _weight = '';
        String _gender = '';
        if (snapshot == null || !snapshot.hasData || snapshot.connectionState == ConnectionState.waiting) {
        } else {
          _age = snapshot.data['age'].toString();
          _weight = snapshot.data['weight'].toString();
          _gender = snapshot.data['gender'].toString();
          // print(snapshot.data.documentID.toString() + " has been found!");
          // print('$_age + $_weight + $_gender');
        }

        return Form(
          key: widget.formKey,
          child: Container(
            key: Key(_userID + _age + _weight + _gender),
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                StandardTextInputField(
                  label: 'Weight',
                  failedValidateText: 'Enter your weight.',
                  initialVal: _weight,
                  updateInputMap: widget.updateInputMap,
                ),
                SizedBox(height: 15.0),
                StandardTextInputField(
                  label: 'Age',
                  failedValidateText: 'Enter your age.',
                  initialVal: _age,
                  updateInputMap: widget.updateInputMap,
                ),
                Container(
                  padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0, bottom: 19.0),
                  alignment: Alignment.centerLeft,
                  child: Text('Gender', style: TextStyle(color: Color(0xff4ff7d3))),
                ),
                GenderRadio(initialVal: _gender)
              ],
            ),
          ),
        );
      },
    );
  }
}

class WebsiteLinks extends StatelessWidget {
  const WebsiteLinks({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Column(
        children: <Widget>[
          Container(
            child: Text(
              "Visit our website and contact us to suggest new resturaunts or workouts you'd like to see!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11.0),
            ),
          ),
          GestureDetector(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
              alignment: Alignment.centerLeft,
              child: Text("Website", style: TextStyle(color: Color(0xff4ff7d3))),
            ),
            onTap: () async {
              if (await canLaunch("https://workitoffapp.com")) {
                await launch("https://workitoffapp.com");
              }
            },
          ),
          GestureDetector(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
              alignment: Alignment.centerLeft,
              child: Container(
                child: Text("Terms of Service", style: TextStyle(color: Color(0xff4ff7d3))),
              ),
            ),
            onTap: () async {
              if (await canLaunch("https://workitoffapp.com/terms.html")) {
                await launch("https://workitoffapp.com/terms.html");
              }
            },
          ),
          GestureDetector(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
              alignment: Alignment.centerLeft,
              child: Text(
                "Privacy Policy",
                style: TextStyle(color: Color(0xff4ff7d3)),
              ),
            ),
            onTap: () async {
              if (await canLaunch("https://workitoffapp.com/privacy.html")) {
                await launch("https://workitoffapp.com/privacy.html");
              }
            },
          ),
        ],
      ),
    );
  }
}

class ProfilePageData extends StatefulWidget {
  ProfilePageData({Key key}) : super(key: key);

  _ProfilePageDataState createState() => _ProfilePageDataState();
}

class _ProfilePageDataState extends State<ProfilePageData> {
  final _formKey = GlobalKey<FormState>();

  // TODO Make this work!!
  Map<String, String> inputMap = {'age': '', 'weight': '', 'gender': ''};

  void _updateInputMap({String age, String weight, String gender}) {
    if (age != null) {
      inputMap['age'] = age;
    }
    if (weight != null) {
      inputMap['weight'] = weight;
    }

    if (gender != null) {
      inputMap['gender'] = gender;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(top: 40.0, bottom: 20.0),
          child: Text('Profile', style: TextStyle(fontSize: 18.0)),
        ),
        Expanded(
          child: ScrollConfiguration(
            behavior: NoOverscrollBehavior(),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  BuildProfileForm(formKey: _formKey, updateInputMap: _updateInputMap),
                  WebsiteLinks(),
                ],
              ),
            ),
          ),
        ),
        UpdateProfileBtn(formKey: _formKey)
      ],
    );
  }
}

class ProfilePage extends StatelessWidget {
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
      child: Container(
        constraints: BoxConstraints.expand(),
        child: ProfilePageData(),
      ),
    );
  }
}

class UpdateProfileBtn extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  UpdateProfileBtn({Key key, @required this.formKey}) : super(key: key);

  _UpdateProfileBtnState createState() => _UpdateProfileBtnState();
}

class _UpdateProfileBtnState extends State<UpdateProfileBtn> with SingleTickerProviderStateMixin {
  AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: Duration(milliseconds: 350), vsync: this);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FadeTransition(
        opacity: CurvedAnimation(parent: _animationController, curve: Curves.linear),
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: FlatButton(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // Removed all padding
            padding: EdgeInsets.zero,
            color: Color(0xff4ff7d3),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.0)),
            child: Text("Update Profile", style: TextStyle(fontSize: 18.0)),
            onPressed: () {
              // If the form validates
              if (widget.formKey.currentState.validate()) {
                showDefualtFlushBar(context: context, text: 'Profile Updated!');
              }
            },
          ),
        ),
      ),
    );
  }
}
