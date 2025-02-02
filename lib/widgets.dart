import 'package:flutter/material.dart';
import 'package:flushbar/flushbar.dart';

//* Contains helpful commonly used widgets

bool isNumeric(String str) {
  if (str == null) {
    return false;
  }
  return double.tryParse(str) != null;
}

class SearchBar extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final double topMargin;
  final double bottomMargin;

  SearchBar({Key key, this.hintText: 'Search', @required this.controller, this.topMargin: 40, this.bottomMargin: 0})
      : super(key: key);

  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  bool empty = true; // Is the textfield empty or not?

  void _clearController() {
    setState(() {
      widget.controller.clear();
      empty = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: widget.topMargin, left: 8.0, right: 8.0, bottom: widget.bottomMargin),
      decoration: BoxDecoration(border: Border.all(width: 1.0), color: Colors.transparent),
      child: TextField(
        onChanged: (text) {
          if (text.isEmpty) {
            setState(() => empty = true);
          } else {
            setState(() => empty = false);
          }
        },
        controller: widget.controller,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 5.0),
          hintText: widget.hintText,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 15),
          prefixIcon: const Icon(Icons.search, color: Color(0xff5a5a5a)),
          suffixIcon: empty
              ? null
              : IconButton(icon: Icon(Icons.clear, size: 20, color: Colors.grey), onPressed: _clearController),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
          enabledBorder: const OutlineInputBorder(borderSide: const BorderSide(style: BorderStyle.none)),
          focusedBorder: const OutlineInputBorder(borderSide: const BorderSide(style: BorderStyle.none)),
        ),
        textAlign: TextAlign.left,
      ),
    );
  }
}

Future<Object> showDefualtFlushBar({@required BuildContext context, @required String text}) {
  return Flushbar(
    // message: 'Profile Updated!',
    messageText: Text(text, style: TextStyle(color: Colors.purple[800])),
    isDismissible: true,
    backgroundColor: Colors.white,
    dismissDirection: FlushbarDismissDirection.HORIZONTAL,
    // reverseAnimationCurve: Curves.decelerate,
    // forwardAnimationCurve: Curves.easeIn,
    duration: const Duration(seconds: 3),
    flushbarPosition: FlushbarPosition.TOP,
  ).show(context);
}

// * Prevent glow effect from overscrolling
class NoOverscrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

BoxDecoration getBasicGradient() {
  return BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: const [Color(0xff170422), Color(0xff9B22E6)],
      stops: const [0.75, 1],
    ),
  );
}
