// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {

  Future addUserDetails(Map<String, dynamic> userInfoMap, String id) async {
    try {
      return await FirebaseFirestore.instance
          .collection("users")
          .doc(id)
          .set(userInfoMap);
    } catch (e) {
      
      print(e.toString());
    }
  }

  Future<bool> editUserDetails(Map<String, dynamic> userInfoMap, String id) async {
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(id)
          .update(userInfoMap);

      return true; // success
    } catch (e) {
      print("Error updating user info: $e");
      return false; // failure
    }
  }

  Future addUserOrderDetails(Map<String, dynamic> userOrderMap, String id, String orderId) async {
    try {
      return await FirebaseFirestore.instance
          .collection("users")
          .doc(id).collection("Orders").doc(orderId)
          .set(userOrderMap);
    } catch (e) {
      
      print(e.toString());
    }
  }

  Future addAdminOrderDetails(Map<String, dynamic> userOrderMap, String orderId) async {
    try {
      return await FirebaseFirestore.instance
          .collection("Orders").doc(orderId)
          .set(userOrderMap);
    } catch (e) {
      
      print(e.toString());
    }
  }

  Future<Stream<QuerySnapshot>> getUserOrders(String id) async {
    try {
      return FirebaseFirestore.instance
          .collection("users")
          .doc(id)
          .collection("Orders")
          .snapshots();
    } catch (e) {
      
      print(e.toString());
      throw Exception("Failed to fetch user orders: $e");
    }
  }

  Future<QuerySnapshot> getUserWalletByEmail(String email) async {
    try {
      return await FirebaseFirestore.instance
          .collection("users")
          .where("email", isEqualTo: email)
          .get();
    } catch (e) {
      
      print(e.toString());
      throw Exception("Failed to fetch user email: $e");
    }
  }

  Future updateUserWallet(String amount, String id) async {
    try {
      return await FirebaseFirestore.instance
          .collection("users")
          .doc(id)
          .update({"wallet":amount});
    } catch (e) {
      
      print(e.toString());
    }
  }

  Future<bool> updateUserPassword(String password, String id) async {
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(id)
          .update({"password": password});
      return true; // Success
    } catch (e) {
      print("Error updating password: $e");
      return false; // Failure
    }
  }

  Future<Stream<QuerySnapshot>> getAdminOrders() async {
    try {
      return FirebaseFirestore.instance
          .collection("Orders")
          .where("Status", isEqualTo: "Pending")
          .snapshots();
    } catch (e) {
      
      print(e.toString());
      throw Exception("Failed to fetch user orders: $e");
    }
  }

  Future updateAdminOrder(String id) async {
    try {
      return await FirebaseFirestore.instance
          .collection("Orders")
          .doc(id)
          .update({"Status":"Delivered"});
    } catch (e) {
      
      print(e.toString());
    }
  }

  Future updateUserOrder(String userid, String docid) async {
    try {
      return await FirebaseFirestore.instance
          .collection("users")
          .doc(userid)
          .collection("Orders")
          .doc(docid)
          .update({"Status":"Delivered"});
    } catch (e) {
      
      print(e.toString());
    }
  }

  Future<Stream<QuerySnapshot>> getAllUsers() async {
    try {
      return FirebaseFirestore.instance
          .collection("users")
          .snapshots();
    } catch (e) {
      
      print(e.toString());
      throw Exception("Failed to fetch user orders: $e");
    }
  }

  Future deleteUser(String id) async {
    try {
      return await FirebaseFirestore.instance
          .collection("users")
          .doc(id)
          .delete();
    } catch (e) {
      
      print(e.toString());
    }
  }

  Future addUserTransaction(Map<String, dynamic> userOrderMap, String id) async {
    try {
      return await FirebaseFirestore.instance
          .collection("users")
          .doc(id).collection("Transaction")
          .add(userOrderMap);
    } catch (e) {
      
      print(e.toString());
    }
  }

  Future<Stream<QuerySnapshot>> getUserTransaction(String id) async {
    try {
      return FirebaseFirestore.instance
          .collection("users")
          .doc(id)
          .collection("Transaction")
          .snapshots();
    } catch (e) {
      
      print(e.toString());
      throw Exception("Failed to fetch user orders: $e");
    }
  }
}