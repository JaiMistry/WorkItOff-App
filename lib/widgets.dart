import 'package:flutter/material.dart';

//* Contains helpful commonly used widgets

class SearchBar extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;

  SearchBar({Key key, this.hintText, this.controller}) : super(key: key);

  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  bool empty = true; // Is the textfield empty or not?

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 40.0, left: 8.0, right: 8.0),
      // padding: EdgeInsets.only(bottom: 0.0),
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
          contentPadding: EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 5.0),
          hintText: widget.hintText,
          hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
          prefixIcon: Icon(Icons.search, color: Color(0xff5a5a5a)),
          suffixIcon: empty
              ? null
              : IconButton(
                  icon: Icon(Icons.clear, size: 20, color: Colors.grey),
                  onPressed: () {
                    setState(() {
                      widget.controller.clear();
                      empty = true;
                    });
                  },
                ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(style: BorderStyle.none)),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(style: BorderStyle.none)),
        ),
        textAlign: TextAlign.left,
      ),
    );
  }
}

// * Prevent glow effect from overscrolling
class NoOverscrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}