import 'package:branch_comm/utils/bcrypt.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final _users = FirebaseFirestore.instance.collection("users");

  Future<String> getNewId() async {
    final docRef = _users.doc();
    return docRef.id; // Returns a new document ID
  }

  //check email exists in users collection
  Future<bool> isEmailExists(String email) async {
    try {
      // Fetch sign-in methods for the email
      final userDoc = await _users.where('email', isEqualTo: email).get();
      
      if (userDoc.docs.isNotEmpty) {
        return true; // Email exists in admin collection
      }

      return false; // Email does not exist

    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        //print('The email address is not valid.');
      }
      return false;
    } catch (e) {
      //print('Error checking email: $e');
      return false;
    }
  }

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

  Future<Map<String, dynamic>?> getUserById(String id) async {
    final doc = await _users.doc(id).get();
    if (doc.exists) {
      return doc.data() as Map<String, dynamic>;
    }
    return null; // Amenity not found
  }

  Future<void> updateUserWallet(String amount, String id) async {
    await _users.doc(id).update({"wallet": amount});
  }

  Future<bool> updateUserPassword(String password, String id) async {
    try {
      await _users.doc(id).update(
        {
          "password": password,
          "encrypt_password": EncryptionService.hashPassword(password),
          "updated_at": FieldValue.serverTimestamp(),
        }
      );
      return true;
    } catch (e) {
      //print("Error updating password: $e");
      return false;
    }
  }

  //get all users by group id
  Future<QuerySnapshot> getAllUsersByGroupId(String groupId) {
    return _users.where("group_id", isEqualTo: groupId).get();
  }

  Stream<QuerySnapshot> getAllUsers() {
    return FirebaseFirestore.instance.collection("users").snapshots();
  }

  //update member status
  Future<bool> updateMemberStatus(String docId, int newStatus) async {
    try {
      await _users.doc(docId).update({
        'status': newStatus,
        'updated_at': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      //print("Error updating member status: $e");
      return false;
    }
  }
  
  Future<bool> deleteUser(String id) async {
    try {
      // Delete from Firestore
      await _users.doc(id).delete();

      // If the user being deleted is the currently logged-in user
      //User? user = FirebaseAuth.instance.currentUser;

      // print((user)?.uid);

      // if (user != null) {
      //   print('here');
      //   await user.delete(); // Deletes from Firebase Authentication
      // }

      return true;
    } catch (e) {
      //print("Error deleting user: $e");
      return false;
    }
  }

  //get uid by email
  Future<String?> getUidFromUserEmail(String email) async {
    try {
      final userDoc = await _users.where('email', isEqualTo: email).get();
      if (userDoc.docs.isNotEmpty) {
        return userDoc.docs.first['uid']; // Return the document ID (uid)
      }
      return null; // Email not found
    } catch (e) {
      //print('Error fetching UID by email: $e');
      return null;
    }
  }

  //get user name by id
  Future<String?> getUserNameById(String userId) async {
    final doc = await _users.doc(userId).get();
    if (doc.exists) {
      return doc['name'] as String?;
    }
    return null; // User not found
  }

  //update user
  Future<bool> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await _users.doc(userId).update(data);
      return true;
    } catch (e) {
      //print("Error updating user: $e");
      return false;
    }
  }
}
