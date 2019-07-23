import 'package:flutter/material.dart';

import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';

import 'package:workitoff/providers/user_provider.dart';

class ProgressPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ProgressPageState();
  }
}

class _ProgressPageState extends State<ProgressPage> {
  // int _currentPercentage = 88;
  // double _calsRemaining = 0.65;
  bool _progressMode = true;

  Widget _renderText(_currentPercentage, _calsRemaining) {
    if (_progressMode) {
      return RichText(
        textAlign: TextAlign.center,
        textScaleFactor: 2,
        text: TextSpan(
          style: const TextStyle(color: Colors.white),
          children: <TextSpan>[
            const TextSpan(text: 'Almost there! Only '),
            TextSpan(
              text: (100 - _currentPercentage).toString() + "%",
              style: TextStyle(color: Color(0xff3ADEA7)),
            ),
            const TextSpan(text: ' remaining!')
          ],
        ),
      );
    } else {
      return RichText(
        textAlign: TextAlign.center,
        textScaleFactor: 2,
        text: TextSpan(
          style: const TextStyle(color: Colors.white),
          children: <TextSpan>[
            TextSpan(
              text: _calsRemaining.toString(),
              style: const TextStyle(color: Color(0xff3ADEA7)),
            ),
            const TextSpan(text: ' calories to work off'),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    WorkItOffUser user = Provider.of<WorkItOffUser>(context);
    int _calsRemaining = 0;
    int _currentPercentage = 0;
    if (user != null) {
      _calsRemaining = (user.calsAdded - user.calsBurned);
      _currentPercentage = (user.calsBurned / user.calsAdded * 100).round();
    }

    // print(user.calsAdded);
    // print(user.calsBurned);
    // print(_currentPercentage);

    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [Color(0xff170422), Color(0xff9B22E6)],
          stops: const [0.75, 1],
        ),
      ),
      child: (user == null)
          ? Container()
          : SafeArea(
              child: Container(
                padding: EdgeInsets.only(top: 30, bottom: 30, left: 10, right: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset('assets/text_logo.png', width: 80),
                    const SizedBox(height: 30),
                    CircularPercentIndicator(
                      animateFromLastPercent: true,
                      animation: true,
                      animationDuration: 700,
                      radius: size.width * 0.75,
                      lineWidth: 21.0,
                      percent: _currentPercentage * .01,
                      center: Text('$_currentPercentage%', style: TextStyle(fontSize: 45)),
                      progressColor: const Color(0xff3ADEA7),
                      backgroundColor: Colors.purple.withOpacity(0.1),
                      reverse: true,
                    ),
                    const SizedBox(height: 15),
                    _renderText(_currentPercentage, _calsRemaining),
                    const SizedBox(height: 20),
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: OutlineButton(
                          child: Text(
                            _progressMode ? 'Show Calories' : 'Show Progress',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            setState(() {
                              _progressMode = !_progressMode;
                            });
                          },
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                          borderSide: const BorderSide(color: Color(0xff17e3f1)),
                          highlightColor: const Color(0xff17e3f1),
                          highlightedBorderColor: const Color(0xff17e3f1),
                          splashColor: Colors.transparent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
