import 'package:flutter/material.dart';
import '../config/theme_config.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _currentTheme = ThemeConfig.leaderTheme;

  ThemeData get currentTheme => _currentTheme;

  void setLeaderTheme() {
    _currentTheme = ThemeConfig.leaderTheme;
    notifyListeners();
  }

  void setMemberTheme() {
    _currentTheme = ThemeConfig.memberTheme;
    notifyListeners();
  }

  void setParentTheme() {
    _currentTheme = ThemeConfig.parentTheme;
    notifyListeners();
  }
}