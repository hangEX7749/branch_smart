import 'package:cloud_firestore/cloud_firestore.dart';

class UserAuthData {
  final _users = FirebaseFirestore.instance.collection("users");

  Future<QuerySnapshot> getUserData(email) async {
    
    var userData = await _users.where("email", isEqualTo: email).get();

    return userData;
  }
}
