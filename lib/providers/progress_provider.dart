import 'package:flutter/foundation.dart';

class ProgressProvider extends ChangeNotifier {
  bool _showProgress;

  set showProgress(bool flag) {
    _showProgress = flag;
    notifyListeners();
  }
  bool get showProgress => _showProgress;
}
