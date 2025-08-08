import 'package:cloud_firestore/cloud_firestore.dart';

class AmenityService {
  final _amenities = FirebaseFirestore.instance.collection("amenities");

  Future<String> getNewId() async {
    final docRef = _amenities.doc();
    return docRef.id; // Returns a new document ID
  }

  //Get amenities name by amenity ID
  Future<String?> getAmenityNameById(String amenityId) async {
    final doc = await _amenities.doc(amenityId).get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      return data['amenity_name'] as String?; // Adjust field name as necessary
    }
    return null; // Amenity not found
  }

  Future<QuerySnapshot<Map<String, dynamic>>> get() async {
    return _amenities.get();
  }

  Future<void> addAmenity(Map<String, dynamic> amenityData) async {
    try {
      final docRef = await _amenities.add(amenityData);
      await docRef.update({'id': docRef.id}); // Update with the new ID
    } catch (e) {
      // Handle error
      //print("Error adding amenity: $e");
    }
  }

  Future<bool> updateAmenity(String amenityId, Map<String, dynamic> data) async {
    try {
      await _amenities.doc(amenityId).update(data);
      return true; 
    } catch (e) {
      // Handle error
      return false; // Return false if update fails
    }
  }

  //Admin
  Stream<QuerySnapshot> getAllAmenities() {
    return _amenities
      .orderBy('created_at', descending: true) 
      .snapshots();
  }

  // Get amenity by ID
  Future<Map<String, dynamic>?> getAmenityById(String amenityId) async {
    final doc = await _amenities.doc(amenityId).get();
    if (doc.exists) {
      return doc.data() as Map<String, dynamic>;
    }
    return null; // Amenity not found
  }

  Future<bool> updateAmenityStatus(String amenityId, int status) async {

    try {
      await _amenities.doc(amenityId).update({
        'status': status,
        'updated_at': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      // Handle error
      //print("Error updating amenity status: $e");
      return false;
    }
  }

  Future<bool> deleteAmenityById(String amenityId) async {
    try {
      await _amenities.doc(amenityId).delete();
      return true;
    } catch (e) {
      // Handle error
      //print("Error deleting amenity: $e");
      return false;
    } 
  }
}