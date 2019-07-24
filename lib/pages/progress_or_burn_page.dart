import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workitoff/pages/burnpage.dart';
import 'package:workitoff/pages/progress.dart';
import 'package:workitoff/providers/user_provider.dart';
import 'package:workitoff/pages/congrats.dart';

class ProgressOrBurnPage extends StatefulWidget {
  ProgressOrBurnPage({Key key}) : super(key: key);

  _ProgressOrBurnPageState createState() => _ProgressOrBurnPageState();
}

class _ProgressOrBurnPageState extends State<ProgressOrBurnPage> {
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
      decoration: const BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [Color(0xff170422), Color(0xff9B22E6)],
          stops: const [0.75, 1],
        ),
      ),
    );
  }
}
