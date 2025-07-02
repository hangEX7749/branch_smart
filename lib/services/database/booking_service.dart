import 'package:cloud_firestore/cloud_firestore.dart';

class BookingService {
  final _bookings = FirebaseFirestore.instance.collection("bookings");
  //final _users = FirebaseFirestore.instance.collection("users");

  Stream<QuerySnapshot> getUserBookings(String userId) {
    return _bookings
        .where('status', whereIn: [10, 50, 90])
        .where('user_id', isEqualTo: userId)
        .orderBy('date', descending: false) 
        //.orderBy('date')
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
}