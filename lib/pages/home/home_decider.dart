import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workitoff/pages/home/burnpage.dart';
import 'package:workitoff/pages/home/progress.dart';
import 'package:workitoff/providers/user_provider.dart';
import 'package:workitoff/pages/home/congrats.dart';
import 'package:workitoff/widgets.dart';

class HomeDecider extends StatefulWidget {
  HomeDecider({Key key}) : super(key: key);

  _HomeDeciderState createState() => _HomeDeciderState();
}

class _HomeDeciderState extends State<HomeDecider> {
  @override
  Widget build(BuildContext context) {
    WorkItOffUser user = Provider.of<WorkItOffUser>(context);
    int _calsRemaining = 0;
    int _currentPercentage = 0;
    if (user != null) {
      try {
        _calsRemaining = (user.calsAdded - user.calsBurned);
        _currentPercentage = (user.calsBurned / user.calsAdded * 100).round();
      } catch (e) {}

      if (user.calsAdded > 0 && user.calsBurned >= user.calsAdded) {
        return CongratsPage();
      } else if (user.calsAdded > 0) {
        return ProgressPage(_calsRemaining, _currentPercentage);
      }
      return BurnPage();
    }
    return Container(
      decoration: getBasicGradient(),
    );
  }
}
