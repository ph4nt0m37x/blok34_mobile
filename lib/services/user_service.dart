import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';

class UserService {

  Future<void> createUser(AppUser user) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.id)
        .set(user.toJson());
  }

  Future<bool> usernameExists(String username) async {
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();

    return snap.docs.isNotEmpty;
  }

  Future<AppUser?> getUserById(String id) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .get();

    if (!doc.exists) return null;

    return AppUser.fromJson(doc.data()!, doc.id);
  }
}