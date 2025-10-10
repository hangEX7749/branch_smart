import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  
  final String id;
  final String userId;
  final String groupId;
  final String title;
  final String message;
  final int type;
  final bool isRead;
  final Map<String, dynamic>? data;

  //Notification code
  static const int general = 10;
  static const int appointment = 20;
  static const int booking = 30;
  static const int wallPost = 40;
  static const int memberJoined = 50;
  static const int others = 90;

  AppNotification({
    required this.id,
    required this.userId,
    required this.groupId,
    required this.type,
    required this.title,
    required this.message,
    this.isRead = false,
    this.data,
    DateTime? createdAt,
    DateTime? updatedAt,
  });

  factory AppNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppNotification(
      id: doc.id,
      userId: data['userId'] ?? '',
      groupId: data['groupId'] ?? '',
      type: data['type'] ?? AppNotification.others,
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      isRead: data['isRead'] ?? false,
      createdAt: null,
      updatedAt: null,
      data: data['data'], 
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'groupId': groupId,
      'type': type,
      'title': title,
      'message': message,
      'isRead': isRead,
      'data': data,
      'created_at': DateTime.now(),
      'updated_at': DateTime.now(),
    };
  }

  //code to name
  static String typeCodeToName(int type) {
    switch (type) {
      case general:
        return 'General';
      case appointment:
        return 'Appointment';
      case booking:
        return 'Booking';
      case wallPost:
        return 'Wall Post';
      case memberJoined:
        return 'Member Joined';
      default:
        return 'Others';
    }
  }
}