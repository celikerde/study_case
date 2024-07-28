import 'package:flutter/material.dart';

class StateProvider with ChangeNotifier {
  String state = "";
  void assignState(String state1) {
    state = state1;
    notifyListeners();
  }

  String get getState => state;
}
