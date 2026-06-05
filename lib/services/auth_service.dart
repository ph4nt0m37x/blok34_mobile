import 'package:firebase_auth/firebase_auth.dart';

import 'package:blok34_mobile/models/app_user.dart';
import 'user_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();

  Future<String?> register(
      String name,
      String username,
      String email,
      String password,
      ) async {
    try {

      final usernameTaken =
      await _userService.usernameExists(username);

      if (usernameTaken) {
        return 'Username already exists.';
      }

      final credential =
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final appUser = AppUser(
        id: credential.user!.uid,
        name: name,
        username: username,
        email: email,
      );

      await _userService.createUser(appUser);

      return "Success!";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'The account already exists for that email.';
      } else {
        return e.message;
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> login(
      String email,
      String password,
      ) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return "Success!";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential') {
        return 'Invalid login credentials.';
      } else {
        return e.message;
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> getEmail() async {
    return _auth.currentUser?.email;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  User? getCurrentFirebaseUser() {
    return _auth.currentUser;
  }
}