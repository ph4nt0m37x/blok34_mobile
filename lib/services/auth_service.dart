class AuthService {
  String? _currentUser;

  String? get currentUser => _currentUser;

  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (email.isNotEmpty && password.isNotEmpty) {
      _currentUser = email;
      return true;
    }
    return false;
  }

  Future<bool> signup(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (email.isNotEmpty && password.isNotEmpty) {
      _currentUser = email;
      return true;
    }
    return false;
  }

  void logout() {
    _currentUser = null;
  }
}