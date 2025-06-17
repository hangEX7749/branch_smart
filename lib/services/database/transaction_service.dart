import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionService {
  final _users = FirebaseFirestore.instance.collection("users");

  Future<void> addUserTransaction(String userId, Map<String, dynamic> data) async {
    await _users.doc(userId).collection("Transaction").add(data);
  }

  Future<Stream<QuerySnapshot>> getUserTransactions(String userId) async {
    return _users.doc(userId).collection("Transaction").snapshots();
  }
}
