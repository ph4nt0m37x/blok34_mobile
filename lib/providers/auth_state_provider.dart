import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:blok34_mobile/models/app_user.dart';
import 'package:blok34_mobile/services/auth_service.dart';

class AuthStateProvider extends ChangeNotifier {

  final AuthService _authService = AuthService();

  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  // Load user from Firestore after login / app start
  Future<void> loadCurrentUser() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      _currentUser = null;
      notifyListeners();
      return;
    }

    _currentUser = await _authService.loadUserData();
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    notifyListeners();
  }
}