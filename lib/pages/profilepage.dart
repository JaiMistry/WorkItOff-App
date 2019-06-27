import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

bool isNumeric(String s) {
  if (s == null) {
    return false;
  }
  return double.parse(s, (e) => null) != null;
}

Widget buildTextFormField({label: String, failedValidateText: String}) {
  return TextFormField(
    validator: (string) {
      if (string.isEmpty || !isNumeric(string)) {
        return failedValidateText;
      }
      return null;
    },
    inputFormatters: [LengthLimitingTextInputFormatter(3)],
    keyboardType: TextInputType.number,
    // autovalidate: true,
    cursorColor: Color(0xff4ff7d3),
    decoration: InputDecoration(
      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
      labelText: label,
      filled: true,
      fillColor: Colors.black38,
      labelStyle: TextStyle(color: Colors.grey),
    ),
    style: TextStyle(color: Colors.white),
  );
}

class GenderRadio extends StatefulWidget {
  GenderRadio({Key key}) : super(key: key);

  _GenderRadioState createState() => _GenderRadioState();
}

class _GenderRadioState extends State<GenderRadio> {
  int _selected = 0;
  Map<int, bool> _genderMapping = {0: false, 1: false}; // Handles whether item is selected or not

  void onRadioChanged(int value) {
    setState(() {
      _selected = value;
      _genderMapping[value] = true; // Change the slected item
      value == 0 ? _genderMapping[1] = false : _genderMapping[0] = false; // Remove unslected item
    });
  }

  List<Widget> makeRadios() {
    List<String> twoGenders = ['Male', 'Female'];

    List<Widget> list = List<Widget>();

    // for (int i = 0; i < twoGenders.length; i++) {
    //   list.add(Material(
    //     color: Colors.transparent,
    //     child: InkWell(
    //       onTap: () {},
    //       // highlightColor: Colors.grey,
    //       // splashColor: Colors.green,
    //       child: Row(
    //         children: <Widget>[
    //           Container(alignment: Alignment.centerRight, child: Text(twoGenders.elementAt(i))),
    //           Radio(
    //             value: i,
    //             groupValue: _selected,
    //             onChanged: (int value) {
    //               onRadioChanged(value);
    //             },
    //           ),
    //         ],
    //       ),
    //     ),
    //   ));
    // }

    for (int i = 0; i < twoGenders.length; i++) {
      list.add(Material(
        color: Colors.transparent,
        child: Theme(
          data: ThemeData.dark(),
          child: RadioListTile(
            value: i,
            controlAffinity: ListTileControlAffinity.trailing,
            // dense: true,
            title: Text(twoGenders.elementAt(i),
                style: TextStyle(color: _genderMapping[i] ? Color(0xff4ff7d3) : Colors.white)),
            // secondary: Icon(Icons.close),
            // subtitle: Text('TWo genders'),
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
            padding: EdgeInsets.only(top: 40.0),
            child: Text('Profile', style: TextStyle(fontSize: 18.0)),
          ),
          Form(
            key: _formKey,
            child: Container(
              padding: EdgeInsets.all(10.0),
              child: Column(children: <Widget>[
                buildTextFormField(label: 'Weight', failedValidateText: 'Enter your weight.'),
                SizedBox(
                  height: 15.0,
                ),
                buildTextFormField(label: 'Age', failedValidateText: 'Enter your age.'),
                GenderRadio()
              ]),
            ),
          ),
          Container(
            padding: EdgeInsets.all(10.0),
            child: Text(
              "Visit our website and contact us to suggest new resturaunts or workouts you'd like to see",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11.0),
            ),
          ),
          Column(
            children: <Widget>[
              RaisedButton(
                child: Text("Update Profile"),
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    Scaffold.of(context).showSnackBar(SnackBar(content: Text('Processing Data')));
                  }
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}
