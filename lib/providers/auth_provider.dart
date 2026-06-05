import 'package:flutter/material.dart';

import '../models/app_user.dart';

class AuthProvider extends ChangeNotifier {
  AppUser? currentUser;

  bool get isLoggedIn =>
      currentUser != null;

  void setUser(AppUser user) {
    currentUser = user;
    notifyListeners();
  }

  void logout() {
    currentUser = null;
    notifyListeners();
  }
}