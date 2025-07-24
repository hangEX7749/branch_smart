import 'package:cloud_firestore/cloud_firestore.dart';

class MemberGroupService {
  final _memberGroups = FirebaseFirestore.instance.collection("memberGroups");

  Stream<QuerySnapshot> getUserMemberGroups(String userId) {
    return _memberGroups
        .where('members', arrayContains: userId)
        .orderBy('created_at', descending: true)
        .snapshots();
  }

  Future<QuerySnapshot> getMemberGroupById(String groupId) {
    return _memberGroups.where('id', isEqualTo: groupId).get();
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

  Future<void> deleteMemberGroup(String groupId) async {
    await _memberGroups.doc(groupId).delete();
  }

}