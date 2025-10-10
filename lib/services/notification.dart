import 'package:branch_comm/model/app_notification_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Notification Service
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();
 
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _notificationsCollection = 'notifications';

  Future<String> getNewId() async {
    return _firestore.collection(_notificationsCollection).doc().id;
  }

  // Create a notification
  Future<void> createNotification({
    required String userId,
    required String groupId,
    required int type,
    required String title,
    required String message,
    //Map<String, dynamic>? data,
  }) async {
    try {
      final notification = AppNotification(
        id: await getNewId(),
        userId: userId,
        groupId: groupId,
        type: type,
        title: title,
        message: message,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        //data: data,
      );

      await _firestore.collection(_notificationsCollection).add(notification.toMap());
    } catch (e) {
      print('Error creating notification: $e');
    }
  }

  // Get unread notification count for user
  Stream<int> getUnreadCountStream(String userId, {String? groupId}) {
    Query query = _firestore
        .collection(_notificationsCollection)
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false);

    if (groupId != null) {
      query = query.where('groupId', isEqualTo: groupId);
    }

    return query.snapshots().map((snapshot) => snapshot.docs.length);
  }

  // Get notifications for user
  Stream<List<AppNotification>> getNotificationsStream(String userId, {String? groupId}) {
    Query query = _firestore
        .collection(_notificationsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(50);

    if (groupId != null) {
      query = query.where('groupId', isEqualTo: groupId);
    }

    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => AppNotification.fromFirestore(doc)).toList());
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection(_notificationsCollection)
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_notificationsCollection)
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      print('Error marking all as read: $e');
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection(_notificationsCollection).doc(notificationId).delete();
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  // Show in-app notification (SnackBar)
  static void showInAppNotification(
    BuildContext context, {
    required String title,
    required String message,
    required int type,
    Duration duration = const Duration(seconds: 3),
  }) {
    Color backgroundColor;
    IconData icon;

    switch (type) {
      case AppNotification.appointment:
        backgroundColor = Colors.blue;
        icon = Icons.calendar_today;
        break;
      case AppNotification.booking:
        backgroundColor = Colors.green;
        icon = Icons.check_circle;
        break;
      case AppNotification.wallPost:
        backgroundColor = Colors.purple;
        icon = Icons.message;
        break;
      case AppNotification.memberJoined:
        backgroundColor = Colors.orange;
        icon = Icons.person_add;
        break;
      default:
        backgroundColor = Colors.grey[800]!;
        icon = Icons.notifications;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    message,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: duration,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }
}

// Helper methods for common notifications

// For Appointments
class AppointmentNotifications {
  static Future<void> onAppointmentCreated({
    required BuildContext context,
    required String userId,
    required String groupId,
    //required String appointmentDetails,
  }) async {
    await NotificationService().createNotification(
      userId: userId,
      groupId: groupId,
      type: AppNotification.appointment,
      title: 'Appointment Created',
      message: 'Your appointment has been successfully created.',
      // data: {'appointmentDetails': appointmentDetails},
    );

    if (context.mounted) {
      NotificationService.showInAppNotification(
        context,
        title: 'Success!',
        message: 'Your appointment has been created',
        type: AppNotification.appointment,
      );
    }
  }

  static Future<void> onAppointmentFailed({
    required BuildContext context,
    required String userId,
    required String groupId,
    required String error,
  }) async {
    NotificationService.showInAppNotification(
      context,
      title: 'Appointment Failed',
      message: 'Failed to create appointment: $error',
      type: AppNotification.general,
    );
  }

  static Future<void> onAppointmentCancelled({
    required BuildContext context,
    required String userId,
    required String groupId,
    required String appointmentDetails,
  }) async {
    await NotificationService().createNotification(
      userId: userId,
      groupId: groupId,
      type: AppNotification.appointment,
      title: 'Appointment Cancelled',
      message: 'Your appointment has been cancelled: $appointmentDetails',
    );

    NotificationService.showInAppNotification(
      context,
      title: 'Cancelled',
      message: 'Your appointment has been cancelled',
      type: AppNotification.appointment,
    );
  }
}

// For Bookings
class BookingNotifications {
  static Future<void> onBookingCreated({
    required BuildContext context,
    required String userId,
    required String groupId,
    required String facilityName,
    required String bookingDate,
  }) async {
    await NotificationService().createNotification(
      userId: userId,
      groupId: groupId,
      type: AppNotification.booking,
      title: 'Booking Confirmed',
      message: 'Your booking for $facilityName on $bookingDate has been confirmed',
      //data: {'facilityName': facilityName, 'bookingDate': bookingDate},
    );

    NotificationService.showInAppNotification(
      context,
      title: 'Booking Confirmed!',
      message: 'Your facility booking has been confirmed',
      type: AppNotification.booking,
    );
  }

  static Future<void> onBookingFailed({
    required BuildContext context,
    required String userId,
    required String groupId,
    required String error,
  }) async {
    NotificationService.showInAppNotification(
      context,
      title: 'Booking Failed',
      message: 'Failed to create booking: $error',
      type: AppNotification.general,
    );
  }

  static Future<void> onBookingCancelled({
    required BuildContext context,
    required String userId,
    required String groupId,
    required String facilityName,
  }) async {
    await NotificationService().createNotification(
      userId: userId,
      groupId: groupId,
      type: AppNotification.booking,
      title: 'Booking Cancelled',
      message: 'Your booking for $facilityName has been cancelled',
    );

    NotificationService.showInAppNotification(
      context,
      title: 'Cancelled',
      message: 'Your booking has been cancelled',
      type: AppNotification.booking,
    );
  }
}

// For Wall Posts
class WallPostNotifications {
  static Future<void> onPostCreated({
    required BuildContext context,
    required String userId,
    required String groupId,
  }) async {
    await NotificationService().createNotification(
      userId: userId,
      groupId: groupId,
      type: AppNotification.wallPost,
      title: 'Post Shared',
      message: 'Your post has been shared to the community wall',
    );

    NotificationService.showInAppNotification(
      context,
      title: 'Success!',
      message: 'Your post has been shared',
      type: AppNotification.wallPost,
    );
  }

  static Future<void> onPostFailed({
    required BuildContext context,
    required String error,
  }) async {
    NotificationService.showInAppNotification(
      context,
      title: 'Post Failed',
      message: 'Failed to share post: $error',
      type: AppNotification.general,
    );
  }
}

// For Members
class MemberNotifications {
  static Future<void> onMemberJoined({
    required BuildContext context,
    required String userId,
    required String groupId,
    required String groupName,
  }) async {
    await NotificationService().createNotification(
      userId: userId,
      groupId: groupId,
      type: AppNotification.memberJoined,
      title: 'Welcome!',
      message: 'You have successfully joined $groupName',
    );

    NotificationService.showInAppNotification(
      context,
      title: 'Welcome!',
      message: 'You have joined $groupName',
      type: AppNotification.memberJoined,
    );
  }
}