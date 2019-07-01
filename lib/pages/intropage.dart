import 'package:flutter/material.dart';

import 'dart:math';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:flutter_swiper/flutter_swiper.dart';

class GenderSelector extends StatefulWidget {
  GenderSelector({Key key}) : super(key: key);

  _GenderSelectorState createState() => _GenderSelectorState();
}

class _GenderSelectorState extends State<GenderSelector> {
  String _gender = 'male';

  void onGenderChange(String gender) {
    setState(() {
      _gender = gender;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Column(
        children: <Widget>[
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.white,
              ),
              children: <TextSpan>[
                TextSpan(text: 'I am '),
                TextSpan(text: '$_gender', style: TextStyle(color: Color(0xff4ff7d3))),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(
                child: IconButton(
                  icon: Icon(FontAwesomeIcons.male, size: 40.0, color: _gender == 'male' ? Color(0xff4ff7d3) : Colors.white),
                  onPressed: () {
                    onGenderChange('male');
                  },
                ),
              ),
              SizedBox(width: 20.0),
              IconButton(
                icon: Icon(FontAwesomeIcons.female,
                    size: 40.0, color: _gender == 'female' ? Color(0xff4ff7d3) : Colors.white),
                onPressed: () {
                  onGenderChange('female');
                },
              )
            ],
          )
        ],
      ),
    );
  }
}

class AgeSlider extends StatefulWidget {
  AgeSlider({Key key}) : super(key: key);

  _AgeSliderState createState() => _AgeSliderState();
}

class _AgeSliderState extends State<AgeSlider> {
  bool beenTouched = false;
  double _age = 10.0;

  void _setValue(double value) {
    setState(() {
      beenTouched = true;
      _age = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        children: <Widget>[
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.white,
              ),
              children: <TextSpan>[
                TextSpan(text: 'I am '),
                beenTouched ? TextSpan(text: '${_age.toInt()} ', style: TextStyle(color: Color(0xff4ff7d3))) : TextSpan(),
                TextSpan(text: 'years old.'),
              ],
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
              value: _age,  
              onChanged: _setValue,
              min: 10.0,
              max: 75.0,
              divisions: 65,
            ),
          ),
        ],
      ),
    );
  }
}

class IntroPage extends StatelessWidget {
  // const IntroPage({Key key}) : super(key: key);

  final List<Widget> _pages = [
    Container(color: Colors.red, child: Center(child: Text('Page 1'))),
    Container(color: Colors.blue, child: Center(child: Text('Page 2'))),
    Container(color: Colors.green, child: Center(child: Text('Page 3'))),
    Container(color: Colors.yellow, child: Center(child: Text('Page 4'))),
    Container(
        color: Colors.transparent,
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Profile Info', style: TextStyle(color: Colors.white, fontSize: 18.0)),
            Container(
              padding: EdgeInsets.only(top: 8.0),
              width: 250.0,
              child: Text(
                'Help us tune our algorith to you by entering your basic info.',
                style: TextStyle(color: Colors.white, fontSize: 14.0),
                textAlign: TextAlign.center,
              ),
            ),
            GenderSelector(),
            AgeSlider()
          ],
        )))
  ];

  @override
  Widget build(BuildContext context) {
    int _selected_Index = 0;
    final _controller = PageController(viewportFraction: 1.0);

    const _kDuration = const Duration(milliseconds: 300);
    const _kCurve = Curves.ease;

    return Scaffold(
      backgroundColor: Color(0xff170422),
      body: Stack(children: [
        Container(
          child: PageView(
            controller: _controller,
            onPageChanged: (int page) {
              _selected_Index = page;
            },
            children: _pages,
            scrollDirection: Axis.horizontal,
          ),
        ),
        Positioned(
          bottom: 0.0,
          left: 0.0,
          right: 0.0,
          child: Container(
            color: Colors.transparent,
            padding: const EdgeInsets.all(20.0), // Padding of dots from screen bottom
            child: Center(
              child: DotsIndicator(
                // color:  _newColor,
                controller: _controller,
                itemCount: _pages.length,
                onPageSelected: (int page) {
                  _controller.animateToPage(
                    page,
                    duration: _kDuration,
                    curve: _kCurve,
                  );
                },
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

/// An indicator showing the currently selected page of a PageController
class DotsIndicator extends AnimatedWidget {
  DotsIndicator({
    this.controller,
    this.itemCount,
    this.onPageSelected,
    this.color: Colors.white,
  }) : super(listenable: controller);

  final PageController controller; // The PageController that this DotsIndicator is representing.

  final int itemCount; // The number of items managed by the PageController

  final ValueChanged<int> onPageSelected; // Called when a dot is tapped

  final Color color; // The color of the dots. Defaults to `Colors.white`.

  static const double _kDotSize = 8.0; // The base size of the dots

  static const double _kMaxZoom = 2.0; // The increase in the size of the selected dot

  Widget _buildDot(int index) {
    double selectedness = Curves.easeOut.transform(
      max(0.0, 1.0 - ((controller.page ?? controller.initialPage) - index).abs()),
    );

    double zoom = 1.0 + (_kMaxZoom - 1.0) * selectedness;

    // print(controller.page);

    return Container(
      width: 25, // The distance between the center of each dot
      child: Center(
        child: Material(
          color: Colors.white,
          type: MaterialType.circle,
          child: Container(
            width: _kDotSize * zoom,
            height: _kDotSize * zoom,
            child: InkWell(
              onTap: () => onPageSelected(index), // Handles button click
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(itemCount, _buildDot),
    );
  }
}
