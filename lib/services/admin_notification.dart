import 'package:branch_comm/screen/home_page/utils/index.dart';
import 'package:branch_comm/model/app_notification_model.dart';

// Notification Service
class AdminNotificationService {
  static final AdminNotificationService _instance = AdminNotificationService._internal();
  factory AdminNotificationService() => _instance;
  AdminNotificationService._internal();
 
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
      //print('Error creating notification: $e');
    }
  }
 
  // Get notifications for user
  Stream<List<AppNotification>> getNotificationsStream(String userId, {String? groupId}) {
    Query query = _firestore
        .collection(_notificationsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .limit(50);

    if (groupId != null) {
      query = query.where('groupId', isEqualTo: groupId);
    }

    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => AppNotification.fromFirestore(doc)).toList());
  }
}

//Member Group
class AdminEditMemberGroupNotifications {
  static Future<void> updateMemberGroupStatus({
    required String userId,
    required String groupId,
    required int status,
  }) async {

    if (status == MemberGroup.active) {
      await AdminNotificationService().createNotification(
        userId: userId,
        groupId: groupId,
        type: AppNotification.memberJoinedConfirm,
        title: 'Group Join Approved',
        message: 'Your join group request has been approved.',
      );
      return;
    } else if (status == MemberGroup.rejected) {
      await AdminNotificationService().createNotification(
        userId: userId,
        groupId: groupId,
        type: AppNotification.memberJoinedFailed,
        title: 'Group Join Rejected',
        message: 'Your join group request has been rejected.',
      );
      return;
    }
    return;
  }
}