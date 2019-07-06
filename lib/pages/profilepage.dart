import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:flushbar/flushbar.dart';

import 'package:workitoff/widgets.dart';

bool _isNumeric(String str) {
  if (str == null) {
    return false;
  }
  return double.tryParse(str) != null;
}


class StandardTextInputField extends StatefulWidget {
  final String label;
  final String failedValidateText;

  StandardTextInputField({this.label: '', this.failedValidateText: ''});

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
            padding: EdgeInsets.only(
              bottom: 2.0,
            ),
            child: Text(
              widget.label,
              style: TextStyle(color: _labelColor),
            ),
          ),
          TextFormField(
            controller: _controller,
            focusNode: _focusNode,
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
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.zero),
              ),
            ),
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class GenderRadio extends StatefulWidget {
  GenderRadio({Key key}) : super(key: key);

  _GenderRadioState createState() => _GenderRadioState();
}

class _GenderRadioState extends State<GenderRadio> {
  int _selected = 0;
  Map<int, Color> _genderMapping = {0: Colors.white, 1: Colors.white}; // Handles whether item is selected or not

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

class ProfilePage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

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
      child: Column(
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
                    Column(
                      children: <Widget>[
                        Form(
                          key: _formKey,
                          child: Container(
                            padding: EdgeInsets.all(10.0),
                            child: Column(children: <Widget>[
                              StandardTextInputField(label: 'Weight', failedValidateText: 'Enter your weight.'),
                              SizedBox(height: 15.0),
                              StandardTextInputField(label: 'Age', failedValidateText: 'Enter your age.'),
                              Container(
                                  padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0, bottom: 19.0),
                                  alignment: Alignment.centerLeft,
                                  child: Text('Gender', style: TextStyle(color: Color(0xff4ff7d3)))),
                              GenderRadio()
                            ]),
                          ),
                        ),
                        Container(
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
                                      child: Text("Terms of Service", style: TextStyle(color: Color(0xff4ff7d3)))),
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
                                  child: Text("Privacy Policy", style: TextStyle(color: Color(0xff4ff7d3))),
                                ),
                                onTap: () async {
                                  if (await canLaunch("https://workitoffapp.com/privacy.html")) {
                                    await launch("https://workitoffapp.com/privacy.html");
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            child: FlatButton(
              // TODO Make button slightly fade in on tab click
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // Removed all padding
              padding: EdgeInsets.zero,
              color: Color(0xff4ff7d3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.0)),
              child: Text("Update Profile", style: TextStyle(fontSize: 18.0)),
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  // If the form validates
                  // Scaffold.of(context).showSnackBar(SnackBar(content: Text('Processing Data')));
                  Flushbar(
                    // message: 'Profile Updated!',
                    messageText: Text(
                      'Profile Updated!',
                      style: TextStyle(color: Colors.purple[800]),
                    ),
                    isDismissible: true,
                    backgroundColor: Colors.white,
                    dismissDirection: FlushbarDismissDirection.HORIZONTAL,
                    // reverseAnimationCurve: Curves.decelerate,
                    // forwardAnimationCurve: Curves.easeIn,
                    duration: Duration(seconds: 3),
                    flushbarPosition: FlushbarPosition.TOP,
                  ).show(context);
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
