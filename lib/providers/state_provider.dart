import 'package:flutter/material.dart';

class StateProvider with ChangeNotifier {
  String result = "";
  void changeState(String val) {
    result = val;
    notifyListeners();
  }
}
