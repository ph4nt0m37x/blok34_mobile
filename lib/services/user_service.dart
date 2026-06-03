import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class UserService {
  Future<AppUser?> getUserById(String id) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .get();

    if (!doc.exists) return null;

    return AppUser.fromJson(doc.data()!, doc.id);
  }
}