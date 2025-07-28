import 'package:cloud_firestore/cloud_firestore.dart';

class AmenityService {
  final _amenities = FirebaseFirestore.instance.collection("amenities");

  Future<String> getNewId() async {
    final docRef = _amenities.doc();
    return docRef.id; // Returns a new document ID
  }
  Future<void> addAmenity(Map<String, dynamic> amenityData) async {
    try {
      await _amenities.add(amenityData);
    } catch (e) {
      // Handle error
      //print("Error adding amenity: $e");
    }
  }

  Future<void> updateAmenity(String amenityId, Map<String, dynamic> data) async {
    await _amenities.doc(amenityId).update(data);
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

  Future<void> deleteAmenityById(String amenityId) async {
    await _amenities.doc(amenityId).delete();
  }

}