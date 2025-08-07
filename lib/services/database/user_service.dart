import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final _users = FirebaseFirestore.instance.collection("users");

  Future<void> addUserDetails(Map<String, dynamic> data, String id) async {
    await _users.doc(id).set(data);
  }

  Future<bool> editUserDetails(Map<String, dynamic> data, String id) async {
    try {
      await _users.doc(id).update(data);
      return true;
    } catch (e) {
      //print("Error updating user info: $e");
      return false;
    }
  }

  Future<bool> updateProfilePic(String imageUrl, String id) async {
    try {
      await _users.doc(id).update({"profilePic": imageUrl});
      return true;
    } catch (e) {
      //print("Error updating profile picture: $e");
      return false;
    }
  }

  Future<QuerySnapshot> getUserById(String id) {
    return _users.where("id", isEqualTo: id).get();
  }

  Future<void> updateUserWallet(String amount, String id) async {
    await _users.doc(id).update({"wallet": amount});
  }

  Future<bool> updateUserPassword(String password, String id) async {
    try {
      await _users.doc(id).update({"password": password});
      return true;
    } catch (e) {
      //print("Error updating password: $e");
      return false;
    }
  }

  Stream<QuerySnapshot> getAllUsers() {
    return FirebaseFirestore.instance.collection("users").snapshots();
  }
  
  Future<void> deleteUser(String id) async {
    await _users.doc(id).delete();
  }

  //get user name by id
  Future<String?> getUserNameById(String userId) async {
    final doc = await _users.doc(userId).get();
    if (doc.exists) {
      return doc['name'] as String?;
    }
    return null; // User not found
  }
}
