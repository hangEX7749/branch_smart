import 'package:cloud_firestore/cloud_firestore.dart';

class AmenityGroupService {

  final _amenityGroups = FirebaseFirestore.instance.collection("amenityGroups");

  Future<QuerySnapshot<Map<String, dynamic>>> get() async {
    return _amenityGroups.get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getAmenityGroupsByGroupId(String groupId) {
    return _amenityGroups.where('group_id', isEqualTo: groupId).get();
  }

  Future<void> addAmenityGroup(Map<String, dynamic> groupData) async {
    try {      
      //skip if have same amenityId and groupId
      final existing = await _amenityGroups
          .where('group_id', isEqualTo: groupData['group_id'])
          .where('amenity_id', isEqualTo: groupData['amenity_id'])
          .get();
      
      if (existing.docs.isNotEmpty) {
        return; // Amenity group already exists
      }

      final docRef = await _amenityGroups.add(groupData);
      await docRef.update({'id': docRef.id}); // Update with the new ID
    } catch (e) {
      // Handle error
      //print("Error adding amenity group: $e");
    }
  }

  Future<bool> updateAmenityGroup(String groupId, Map<String, dynamic> data) async {
    try {
      await _amenityGroups.doc(groupId).update(data);
      return true; 
    } catch (e) {
      // Handle error
      return false; // Return false if update fails
    }
  }

  Future<bool> clearAmenityGroupById(String groupId, String amenityId) async {

    try {
      final snapshot = await _amenityGroups.where('group_id', isEqualTo: groupId).where('amenity_id', isEqualTo: amenityId).get();
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
      return true;
    } catch (e) {
      // Handle error
      //print("Error clearing amenity group: $e");
      return false;
    }
  }

}