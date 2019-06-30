import 'package:flutter/material.dart';

import 'dart:math';
// import 'package:flutter_swiper/flutter_swiper.dart';

class IntroPage extends StatelessWidget {
  // const IntroPage({Key key}) : super(key: key);

  final List<Widget> _pages = [
    Container(color: Colors.red, child: Center(child: Text('Page 1'))),
    Container(color: Colors.blue, child: Center(child: Text('Page 2'))),
    Container(color: Colors.green, child: Center(child: Text('Page 3'))),
    Container(color: Colors.yellow, child: Center(child: Text('Page 4'))),
    Container(color: Colors.purple, child: Center(child: Text('Page 5')))
  ];


  @override
  Widget build(BuildContext context) {
    int _selected_Index = 0;
    final _controller = PageController(viewportFraction: 0.9);

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
  }): super(listenable: controller);

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
              onTap: () => onPageSelected(index),  // Handles button click
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
