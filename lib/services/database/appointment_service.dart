import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentService {
  final _appointments = FirebaseFirestore.instance.collection("appointments");

  Future<String> getNewId() async {
    return _appointments.doc().id;
  }

  Stream<QuerySnapshot> getUserAppointments(String userId) {
    final now = Timestamp.now();
    return _appointments
        .where('user_id', isEqualTo: userId)
        .where('invite_datetime', isGreaterThan: now)
        //.where('status', isEqualTo: 10)
        .orderBy('invite_datetime', descending: false)
        .snapshots();
  }

  Stream<QuerySnapshot> getPastAppointments(String userId) {
    final now = Timestamp.now();
    return _appointments
        .where('user_id', isEqualTo: userId)
        .where('invite_datetime', isLessThan: now)
        //.where('status', isEqualTo: 10)
        .orderBy('invite_datetime', descending: true)
        .snapshots();
  }

  Future<QuerySnapshot> checkAppointment(String guestName, DateTime inviteDateTime) async {
    return _appointments
        .where('guest_name', isEqualTo: guestName)
        //.where('appointment_type', isEqualTo: 'invite')
        .where('invite_datetime', isEqualTo: inviteDateTime)
        .get();
  }

  //check if appointment already exists
  Future<bool> appointmentExists({required String userId, required String groupId, required DateTime inviteDateTime}) async {
    try {
      final snapshot = await _appointments
        .where('user_id', isEqualTo: userId)
        .where('group_id', isEqualTo: groupId)
        .where('invite_datetime', isEqualTo: inviteDateTime)
        .get();
        return snapshot.docs.isNotEmpty;

    } catch (e) {
      //print("Error checking appointment: $e");
      return false;
    }
  }

  Future<bool> addAppointment(Map<String, dynamic> appointmentMap, String appointmentId) async {
    try {
      await _appointments.doc(appointmentId).set(appointmentMap);
      return true;
    } catch (e) {
      //print("Error adding appointment: $e");
      return false;
    }
  }

  Future<void> updateAppointment(String appointmentId, Map<String, dynamic> data) async {
    await _appointments.doc(appointmentId).update(data);
  }

  Future<void> deleteAppointment(String appointmentId) async {
    await _appointments.doc(appointmentId).delete();
  }


  //Admin
  Stream<QuerySnapshot> getAllAppointments() {
    return _appointments.orderBy('invite_datetime', descending: true).snapshots();
  }

  Future<void> updateAppointmentStatus(String appointmentId, int status) async {
    await _appointments.doc(appointmentId).update({
      'status': status,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }
}