import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:blok34_mobile/services/cloudinary_service.dart';
import 'package:blok34_mobile/models/app_user.dart';
import 'user_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final CloudinaryService _cloudinaryService = CloudinaryService();

  // ============ AUTHENTICATION METHODS ============

  Future<String?> register(
      String name,
      String username,
      String email,
      String password,
      ) async {
    try {
      final usernameTaken = await _userService.usernameExists(username);

      if (usernameTaken) {
        return 'Username already exists.';
      }

      final credential = await _auth.createUserWithEmailAndPassword(
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

  // ============ PROFILE METHODS ============

  // Get current user as AppUser
  Future<AppUser?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;

    try {
      final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        return AppUser(
          id: firebaseUser.uid,
          name: userData['name'] ?? firebaseUser.displayName ?? '',
          username: userData['username'] ?? '',
          email: userData['email'] ?? firebaseUser.email ?? '',
          photoUrl: userData['photoUrl'] ?? firebaseUser.photoURL,
          bio: userData['bio'] ?? '',
        );
      } else {
        return AppUser(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? '',
          username: '',
          email: firebaseUser.email ?? '',
          photoUrl: firebaseUser.photoURL,
          bio: '',
        );
      }
    } catch (e) {
      return null;
    }
  }

  // Load user data
  Future<AppUser> loadUserData() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        return AppUser(
          id: user.uid,
          name: userData['name'] ?? user.displayName ?? '',
          username: userData['username'] ?? '',
          email: userData['email'] ?? user.email ?? '',
          photoUrl: userData['photoUrl'] ?? user.photoURL,
          bio: userData['bio'] ?? '',
        );
      } else {
        final appUser = AppUser(
          id: user.uid,
          name: user.displayName ?? '',
          username: user.email?.split('@').first ?? '',
          email: user.email ?? '',
          photoUrl: user.photoURL,
          bio: '',
        );
        await _firestore.collection('users').doc(user.uid).set(appUser.toJson());
        return appUser;
      }
    } catch (e) {
      throw Exception('Error loading user data: $e');
    }
  }

  Future<String> uploadProfilePicture(
      File imageFile,
      ) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User not logged in');
    }

    final imageUrl =
    await _cloudinaryService.uploadImage(
      imageFile,
      folder: 'profile_pictures',
    );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({
      'photoUrl': imageUrl,
    });

    return imageUrl;
  }

  Future<void> updateProfile({
    required String name,
    required String username,
    required String bio,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    try {
      if (name.isNotEmpty) {
        await user.updateDisplayName(name);
      }

      await _firestore.collection('users').doc(user.uid).update({
        'name': name,
        'username': username,
        'bio': bio,
      });

      await user.reload();
    } catch (e) {
      throw Exception('Error updating profile: $e');
    }
  }

  Future<bool> isUsernameAvailable(String username) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return true;
      }

      return querySnapshot.docs.first.id == currentUser.uid;
    } catch (e) {
      throw Exception('Error checking username availability: $e');
    }
  }

  // Update password
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        throw Exception('Current password is incorrect');
      } else if (e.code == 'weak-password') {
        throw Exception('Password should be at least 6 characters');
      } else {
        throw Exception('Error updating password: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error updating password: $e');
    }
  }

  // Update email
  Future<void> updateEmail({
    required String newEmail,
    required String password,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
      await user.verifyBeforeUpdateEmail(newEmail);

      await _firestore.collection('users').doc(user.uid).update({
        'email': newEmail,
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        throw Exception('Password is incorrect');
      } else if (e.code == 'requires-recent-login') {
        throw Exception('Please log out and log in again to change email');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('This email is already in use');
      } else {
        throw Exception('Error updating email: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error updating email: $e');
    }
  }

  Future<File?> pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 500,
      maxHeight: 500,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  Future<File?> pickImageFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 500,
      maxHeight: 500,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

}