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
      if (string.isEmpty == true || isNumeric(string) == false) {
        return failedValidateText;
      }
      return null;
    },
    inputFormatters: [LengthLimitingTextInputFormatter(3)],
    keyboardType: TextInputType.number,
    // autovalidate: true,
    cursorColor: Colors.teal[300],
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

Widget buildGenderFild(){
  return Container();
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
                SizedBox(height: 15.0,),
                buildTextFormField(label: 'Age', failedValidateText: 'Enter your age.'),
                buildGenderFild()
              ]),
            ),
          ),
          RaisedButton(
            child: Text("UPDATE PROFILE"),
            onPressed: () {
              if (_formKey.currentState.validate()) {
                Scaffold.of(context).showSnackBar(SnackBar(content: Text('Processing Data')));
              }
            },
          )
        ],
      ),
    );
  }
}
