import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminService {
  
  final _admins = FirebaseFirestore.instance.collection("admins");

  //check email exists in admin collection
  Future<bool> isEmailExists(String email) async {
    try {
      // Fetch sign-in methods for the email
      final adminDoc = await _admins.where('email', isEqualTo: email).get();
      
      if (adminDoc.docs.isNotEmpty) {
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

  //get uid by email
  Future<String?> getUidFromAdminEmail(String email) async {
    try {
      final adminDoc = await _admins.where('email', isEqualTo: email).get();
      if (adminDoc.docs.isNotEmpty) {
        return adminDoc.docs.first.id; // Return the document ID (uid)
      }
      return null; // Email not found
    } catch (e) {
      //print('Error fetching UID by email: $e');
      return null;
    }
  }

}
