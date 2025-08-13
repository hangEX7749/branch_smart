import 'package:cloud_firestore/cloud_firestore.dart';

class BookingService {
  final _bookings = FirebaseFirestore.instance.collection("bookings");
  //final _users = FirebaseFirestore.instance.collection("users");

  Future<String> getNewId() async {
    final docRef = _bookings.doc();
    return docRef.id;
  }

  Stream<QuerySnapshot> getUserBookings(String? userId, String? groupId) {
    try {
      return _bookings
        .where('status', whereIn: [10, 30, 90])
        .where('user_id', isEqualTo: userId)
        .where('group_id', isEqualTo: groupId)
        .orderBy('date', descending: false) 
        .snapshots();
    } catch (e) {
      //print("Error getting user bookings: $e");
      return Stream.empty();
    }
  }

  Stream<QuerySnapshot> getPastBookings(String? userId, String? groupId) {
    final now = Timestamp.now();
    return _bookings
        .where('status', whereIn: [10,90])
        .where('user_id', isEqualTo: userId)
        .where('group_id', isEqualTo: groupId)
        .where('date', isLessThan: now)
        .orderBy('date', descending: true)
        .snapshots();
  }

  Future <QuerySnapshot> checkBooking(String anemity, String date, String time) async {
    return _bookings
        .where('amenity', isEqualTo: anemity)
        .where('date', isEqualTo: date)
        .where('time', isEqualTo: time)
        .get();
  }

  Future<bool> addBooking(Map<String, dynamic> bookingMap, String bookingId) async {
    try {
      await _bookings.doc(bookingId).set(bookingMap);
      return true;
    } catch (e) {
      //print("Error adding booking: $e");
      return false;
    }
  }

  Future<QuerySnapshot> getBookingsByUserId(String userId) async {
    return await _bookings.where("userId", isEqualTo: userId).get();
  }

  Future<void> updateBooking(String bookingId, Map<String, dynamic> data) async {
    await _bookings.doc(bookingId).update(data);
  }

  Future<void> deleteBooking(String bookingId) async {
    await _bookings.doc(bookingId).delete();
  }

  //Admin
  Stream<QuerySnapshot> getAllBookings() {
    return _bookings
      .orderBy('created_at', descending: true) 
      .snapshots();
  }
}