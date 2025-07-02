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

  Future<QuerySnapshot> getUserWalletByEmail(String email) async {
    return await _users.where("email", isEqualTo: email).get();
  }

  Future<QuerySnapshot> getUserById(String id) async {
    return await _users.where("id", isEqualTo: id).get();
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
}
