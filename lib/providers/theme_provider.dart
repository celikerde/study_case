import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData;
  ThemeProvider(this._themeData);
  getThemeData() => _themeData;
  setThemeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }
}
