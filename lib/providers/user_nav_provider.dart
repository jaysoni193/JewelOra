import 'package:flutter/foundation.dart';

class UserNavProvider extends ChangeNotifier {
  static const int homeTab = 0;
  static const int shopTab = 1;
  static const int cartTab = 2;
  static const int profileTab = 3;

  int _index = homeTab;
  int get index => _index;

  void setIndex(int value) {
    if (value == _index) return;
    _index = value;
    notifyListeners();
  }
}