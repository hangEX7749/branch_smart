import 'package:cloud_firestore/cloud_firestore.dart';

class OrderService {
  final _orders = FirebaseFirestore.instance.collection("Orders");
  final _users = FirebaseFirestore.instance.collection("users");

  Future<void> addUserOrder(String userId, String orderId, Map<String, dynamic> data) async {
    await _users.doc(userId).collection("Orders").doc(orderId).set(data);
  }

  Future<void> addAdminOrder(String orderId, Map<String, dynamic> data) async {
    await _orders.doc(orderId).set(data);
  }

  Future<Stream<QuerySnapshot>> getUserOrders(String userId) async {
    return _users.doc(userId).collection("Orders").snapshots();
  }

  Future<Stream<QuerySnapshot>> getAdminOrders() async {
    return _orders.where("Status", isEqualTo: "Pending").snapshots();
  }

  Future<void> updateAdminOrder(String id) async {
    await _orders.doc(id).update({"Status": "Delivered"});
  }

  Future<void> updateUserOrder(String userId, String orderId) async {
    await _users.doc(userId).collection("Orders").doc(orderId).update({"Status": "Delivered"});
  }
}
