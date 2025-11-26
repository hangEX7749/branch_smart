import 'package:branch_comm/model/member_group_model.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class MemberGroupService {
  final _memberGroups = FirebaseFirestore.instance.collection("memberGroups");

  Stream<QuerySnapshot> getUserMemberGroups(String userId) {
    return _memberGroups
        .where('user_id', arrayContains: userId)
        .orderBy('created_at', descending: true)
        .snapshots();
  }

  Future<QuerySnapshot> getMemberGroupByUserId(String userId) {
    return _memberGroups
      .where('user_id', isEqualTo: userId)
      .where('status', isEqualTo: MemberGroup.active)
      .get();
  }

  Future<QuerySnapshot> getAllMemberGroupsByGroupId(String groupId) {
    return _memberGroups
      .where('group_id', isEqualTo: groupId)
      .where('status', isEqualTo: MemberGroup.active)
      .get();
  }

  Future<bool> addMemberGroup(Map<String, dynamic> memberGroupData) async {
    try {
      await _memberGroups.add(memberGroupData);
      return true;
    } catch (e) {
      //print("Error adding member group: $e");
      return false;
    }
  }

  Future<String> getNewId() async {
    final docRef = _memberGroups.doc();
    return docRef.id; // Returns a new document ID
  }

  //if memeber id, group id already exists, return true
  Future<bool> memberGroupExists(String memberId, String groupId) async
  {
    final snapshot = await _memberGroups
        .where('user_id', isEqualTo: memberId)
        .where('group_id', isEqualTo: groupId)
        .get();

    return snapshot.docs.isNotEmpty;
  } 

  Future<void> updateMemberGroup(String groupId, Map<String, dynamic> data) async {
    await _memberGroups.doc(groupId).update(data);
  }

  //updateMemberGroupStatus
  Future<void> updateMemberGroupStatus(String groupId, int status) async {
    await _memberGroups.doc(groupId).update({'status': status});
  }

  Future<void> deleteMemberGroup(String groupId) async {
    await _memberGroups.doc(groupId).delete();
  }

  //admin
  Stream<QuerySnapshot> getAllMemberGroups() {
    return _memberGroups
        .orderBy('created_at', descending: true)
        .snapshots();
  }

}