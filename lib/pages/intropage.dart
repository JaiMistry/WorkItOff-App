import 'dart:math';
import 'package:flutter/material.dart';

import 'package:workitoff/navigation_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GenderSelector extends StatefulWidget {
  final Function(String) genderCallback; // Used to send data back to the parent

  GenderSelector(this.genderCallback);
  // GenderSelector({Key key, this.genderCallback}) : super(key: key);

  _GenderSelectorState createState() => _GenderSelectorState();
}

class _GenderSelectorState extends State<GenderSelector> {
  String _gender = '';

  void onGenderChange(String gender) {
    setState(() {
      // this.widget.createState();
      widget.genderCallback(gender);
      _gender = gender;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15.0),
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
                  icon: Icon(
                    FontAwesomeIcons.male,
                    size: 45.0,
                    color: _gender == 'male' ? Color(0xff4ff7d3) : Colors.white,
                  ),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onPressed: () {
                    onGenderChange('male');
                  },
                ),
              ),
              SizedBox(width: 80.0),
              IconButton(
                icon: Icon(
                  FontAwesomeIcons.female,
                  size: 45.0,
                  color: _gender == 'female' ? Color(0xff4ff7d3) : Colors.white,
                ),
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
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

class CustomSlider extends StatefulWidget {
  final String leadingText;
  final String trailingText;
  final double minSliderVal;
  final double maxSliderVal;
  final Function(int) callback;

  CustomSlider({Key key, this.leadingText, this.trailingText, this.minSliderVal, this.maxSliderVal, this.callback})
      : super(key: key);

  _CustomSliderState createState() => _CustomSliderState(val: minSliderVal);
}

class _CustomSliderState extends State<CustomSlider> {
  double val; // Contains the value of the slider

  _CustomSliderState({this.val: 10.0});

  bool beenTouched = false;

  void _setValue(double value) {
    setState(() {
      beenTouched = true;
      widget.callback(val.toInt());
      val = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        children: <Widget>[
          SizedBox(height: 10.0),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.white,
              ),
              children: <TextSpan>[
                TextSpan(text: widget.leadingText),
                beenTouched
                    ? TextSpan(text: '${val.toInt()} ', style: TextStyle(color: Color(0xff4ff7d3)))
                    : TextSpan(),
                TextSpan(text: widget.trailingText),
              ],
            ),
          ),
          SizedBox(height: 10.0),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
                thumbColor: val == widget.minSliderVal ? Colors.white : Color(0xff3ADEA7),
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10.0),
                activeTrackColor: Color(0xff3ADEA7),
                inactiveTrackColor: Colors.grey,
                overlayColor: Colors.transparent,
                trackHeight: 1.0),
            child: Slider(
              value: val,
              onChanged: _setValue,
              min: widget.minSliderVal,
              max: widget.maxSliderVal,
              divisions: widget.maxSliderVal.toInt() - widget.minSliderVal.toInt(),
            ),
          ),
        ],
      ),
    );
  }
}

class StartButton extends StatelessWidget {
  final bool startReady; // Indicates whether the user has inputted all data and is ready to proceed
  const StartButton({Key key, this.startReady}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(top: 20.0, bottom: 4.0),
          child: this.startReady
              ? Text("You're all set!", style: TextStyle(fontSize: 18.0))
              : Text('Almost Done!', style: TextStyle(fontSize: 18.0)),
        ),
        SizedBox(height: 4.0),
        RaisedButton(
          child: Text('Start Work It Off'),
          color: Color(0xff3ADEA7),
          disabledColor: Colors.teal[900],
          disabledTextColor: Colors.black,
          onPressed: this.startReady
              ? () => Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (BuildContext context) => NavigationBar()))
              : null,
        ),
      ],
    );
  }
}

class PageData extends StatelessWidget {
  final String title;
  final String message;
  final String imagePath;
  const PageData({Key key, this.title, this.message, this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(imagePath, width: 275),
          SizedBox(height: 10.0),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20.0,
              color: Color(0xff4ff7d3),
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 10.0),
            width: 260.0,
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ),
            ),
          ),
          SizedBox(height: 30.0),
        ],
      ),
    );
  }
}

class InputPage extends StatefulWidget {
  InputPage({Key key}) : super(key: key);

  _InputPageState createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> with AutomaticKeepAliveClientMixin<InputPage> {
  @override
  bool get wantKeepAlive => true; // Maintains the page state even the the page is changed

  bool _genderSelected = false;
  bool _weightSelected = false;
  bool _ageSelected = false;
  bool _allItemsCompleted = false;

  void _genderCallback(String gender) {
    _genderSelected = true;
    checkProfileCompletion();
  }

  void _weightCallback(int weight) {
    _weightSelected = true;
    checkProfileCompletion();
  }

  void _ageCallback(int age) {
    _ageSelected = true;
    checkProfileCompletion();
  }

  void checkProfileCompletion() {
    if (_genderSelected & _weightSelected & _ageSelected) {
      setState(() {
        _allItemsCompleted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Container(
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
              GenderSelector(_genderCallback),
              CustomSlider(
                leadingText: 'I am ',
                trailingText: 'years old.',
                minSliderVal: 10,
                maxSliderVal: 75,
                callback: _ageCallback,
              ),
              CustomSlider(
                leadingText: 'I weigh ',
                trailingText: 'lbs.',
                minSliderVal: 80,
                maxSliderVal: 450,
                callback: _weightCallback,
              ),
              StartButton(startReady: _allItemsCompleted)
            ],
          ),
        ),
      ),
    );
  }
}

class NoOverscrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

class IntroPage extends StatelessWidget {
  // const IntroPage({Key key}) : super(key: key);

  final List<Widget> _pages = [
    Container(
      child: PageData(
        title: 'Welcome to Work It Off!',
        message: 'Get started on living healthy without making compromises.',
        imagePath: 'assets/intro_images/page1.jpg',
      ),
    ),
    Container(
      child: PageData(
        title: 'Cheat Meals',
        message: 'Indulge in the foods you love and add them to the app.',
        imagePath: 'assets/intro_images/page2.jpg',
      ),
    ),
    Container(
      child: PageData(
        title: 'Workouts',
        message: 'Work off those meals by selecting from a wide variety of workouts.',
        imagePath: 'assets/intro_images/page3.jpg',
      ),
    ),
    Container(
      child: PageData(
        title: 'Dashboard',
        message: 'Watch your progress as you refocus on enjoying life while living healthy.',
        imagePath: 'assets/intro_images/page4.jpg',
      ),
    ),
    InputPage()
  ];

  @override
  Widget build(BuildContext context) {
    // int _selected_Index = 0;
    final _controller = PageController(viewportFraction: 1.0);

    const _kDuration = const Duration(milliseconds: 300);
    const _kCurve = Curves.ease;

    return Scaffold(
      backgroundColor: Color(0xff170422),
      body: Stack(children: [
        Container(
          child: ScrollConfiguration(
            behavior: NoOverscrollBehavior(),
            child: PageView(
              physics: BouncingScrollPhysics(),
              controller: _controller,
              // onPageChanged: (int page) {
              //   _selected_Index = page;
              // },
              children: _pages,
              scrollDirection: Axis.horizontal,
            ),
          ),
        ),
        Positioned(
          bottom: 0.0,
          left: 0.0,
          right: 0.0,
          child: Container(
            color: Colors.transparent,
            padding: const EdgeInsets.all(12.0), // Padding of dots from screen bottom
            child: Center(
              child: DotsIndicator(
                mainColor: Colors.purple[200].withOpacity(0.2),
                selectedColor: Colors.purple[200],
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
    this.mainColor: Colors.white,
    this.selectedColor: Colors.blue,
  }) : super(listenable: controller);

  final PageController controller; // The PageController that this DotsIndicator is representing.
  final int itemCount; // The number of items managed by the PageController
  final ValueChanged<int> onPageSelected; // Called when a dot is tapped
  final Color mainColor; // The color of the dots. Defaults to `Colors.white`.
  final Color selectedColor; // The color of the SELECTED dot. Defaults to `Colors.blue`.
  static const double _kDotSize = 8.0; // The base size of the dots
  static const double _kMaxZoom = 1.0; // The increase in the size of the selected dot. 1.0 = no change

  Widget _buildDot(int index) {
    double selectedness = Curves.easeOut.transform(
      max(0.0, 1.0 - ((controller.page ?? controller.initialPage) - index).abs()),
    );

    double zoom = 1.0 + (_kMaxZoom - 1.0) * selectedness;

    return Container(
      width: 25, // The distance between the center of each dot
      child: Center(
        child: Material(
          color: (controller.page == null && index == 0)
              ? selectedColor
              : (controller.page == null && index != 0)
                  ? mainColor
                  : (controller.page.round() == index) ? selectedColor : mainColor,
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
