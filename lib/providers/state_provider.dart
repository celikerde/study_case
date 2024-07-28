import 'package:flutter/material.dart';

class StateProvider with ChangeNotifier {
  String state = "";
  void assignState(String newState) {
    state = newState;
    notifyListeners();
  }

  String get getState => state;
}
