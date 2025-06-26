import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserAuthData {
  final _users = FirebaseFirestore.instance.collection("users");

  Future<QuerySnapshot> getUserData(email) async {
    
    var userData = await _users.where("email", isEqualTo: email).get();

    return userData;


    // final user = FirebaseAuth.instance.currentUser;
    // if (user == null) {
    //   throw Exception('No user is signed in.');
    // }

    // if (user != null) {
    //   final uid = user.uid;
    //   final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

    //   print(doc);

    //   if (doc.exists) {
    //     final userData = doc.data();
    //     print('User data: $userData');
    //     // Example: String name = userData['name'];
    //     // Return the user's collection as a QuerySnapshot
    //     return await FirebaseFirestore.instance
    //         .collection('users')
    //         .where(FieldPath.documentId, isEqualTo: uid)
    //         .get();
    //   } else {
    //     print('No user document found for UID: $uid');
    //     throw Exception('No user document found for UID: $uid');
    //   }
    // } else {
    //   print('No user is signed in.');
    //   throw Exception('No user is signed in.');
    // }
  }
}
