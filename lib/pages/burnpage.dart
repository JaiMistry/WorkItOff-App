import 'package:flutter/material.dart';

class BurnPage extends StatelessWidget {
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
          Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 40.0),
                child: Image.asset('assets/text_logo.png', width: 80),
              ),
              SizedBox(height: 50),
              Image.asset('assets/logo_transparent.png', height: 300),
              SizedBox(height: 50),
              Container(
                child: Column(
                  children: <Widget>[
                    Text(
                      'Enjoy something',
                      style: TextStyle(color: Colors.white, fontSize: 25.0),
                    ),
                    Text(
                      'delicious... come back and',
                      style: TextStyle(color: Colors.white, fontSize: 25.0),
                    ),
                    Text(
                      'Work It Off!',
                      style:
                          TextStyle(color: Color(0xff3ADEA7), fontSize: 25.0),
                    ),
                    SizedBox(
                      width: 60.0,
                      child: OutlineButton(
                        child:
                            Text('Go!', style: TextStyle(color: Colors.white)),
                        onPressed: () {},
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(20.0),
                        ),
                        borderSide: BorderSide(color: Color(0xff17e3f1)),
                        highlightColor: Color(0xff17e3f1),
                        highlightedBorderColor: Color(0xff17e3f1),
                        splashColor: Colors.transparent,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
