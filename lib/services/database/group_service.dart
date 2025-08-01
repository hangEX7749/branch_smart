import 'package:branch_comm/model/group_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupService {
  final _groups = FirebaseFirestore.instance.collection("groups");

  Stream<QuerySnapshot> getUserGroups(String userId) {
    return _groups
        .where('members', arrayContains: userId)
        .orderBy('created_at', descending: true)
        .snapshots();
  }

  Future<bool> addGroup(Map<String, dynamic> groupData) async {
    try {
      final docRef = await _groups.add(groupData);
      await docRef.update({'id': docRef.id});
      return true;
    } catch (e) {
      //print("Error adding group: $e");
      return false;
    }
  }

  Future<bool> updateGroup(String groupId, Map<String, dynamic> data) async {
    try {
      await _groups.doc(groupId).update(data);
      return true;
    } catch (e) {
      //print("Error updating group: $e");
      return false;
    }
  }

  Future<bool> deleteGroupById(String groupId) async {
    try {
      await _groups.doc(groupId).delete();
      return true;
    } catch (e) {
      // Handle error
      return false;
    }
  }

  //Dropdown options for group name and id as value
  Future<List<Map<String, dynamic>>> getGroupDropdownOptions() async {
    final snapshot = await _groups.get();
    return snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        'name': doc['group_name'],
      };
    }).toList();
  }

  //Admin
  Future<Map<String, dynamic>?> getGroupById(String groupId) async {
    final doc = await _groups.doc(groupId).get();
    //print(doc.data());
    if (doc.exists) {
      return doc.data() as Map<String, dynamic>;
    }
    return null; // Group not found
  }

  Stream<QuerySnapshot> getGroupsStream(String status, DateTime? startDate, DateTime? endDate) {
    Query query = _groups;

    if (status != 'All') {
      final int? statusCode = Group.statusFilterOptions[status];
      if (statusCode != null) {
        query = query.where('status', isEqualTo: statusCode);
      }
    }

    if (startDate != null && endDate != null) {
      query = query.where('created_at', isGreaterThanOrEqualTo: startDate)
                   .where('created_at', isLessThanOrEqualTo: endDate);
    }

    return query.orderBy('created_at', descending: true).snapshots();
  }
}