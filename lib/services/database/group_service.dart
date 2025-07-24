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

  Future<QuerySnapshot> getGroupById(String groupId) {
    return _groups.where('id', isEqualTo: groupId).get();
  }

  Future<bool> addGroup(Map<String, dynamic> groupData) async {
    try {
      await _groups.add(groupData);
      return true;
    } catch (e) {
      //print("Error adding group: $e");
      return false;
    }
  }

  Future<void> updateGroup(String groupId, Map<String, dynamic> data) async {
    await _groups.doc(groupId).update(data);
  }

  Future<void> deleteGroup(String groupId) async {
    await _groups.doc(groupId).delete();
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