import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class FoodItemProvider extends ChangeNotifier {
  DocumentSnapshot _currentRestaurant;

  set currentRestuarant(DocumentSnapshot snap) {
    _currentRestaurant = snap;
    notifyListeners();
  }

  DocumentSnapshot get currentRestuarant {
    return _currentRestaurant;
  }
}