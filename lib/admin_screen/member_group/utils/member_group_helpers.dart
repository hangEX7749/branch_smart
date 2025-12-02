import 'package:branch_comm/services/admin_notification.dart';
import 'package:flutter/material.dart';
import 'package:branch_comm/model/member_group_model.dart';
import 'package:branch_comm/services/database/member_group_service.dart';

class MemberGroupHelpers {
  static Color getStatusColor(int? status) {
    switch (status) {
      case MemberGroup.active:
        return Colors.green;
      case MemberGroup.pending:
        return Colors.orange;
      case MemberGroup.inactive:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  static String getStatusText(int? status) {
    switch (status) {
      case MemberGroup.active:
        return 'Active';
      case MemberGroup.pending:
        return 'Pending';
      case MemberGroup.inactive:
        return 'Inactive';
      default:
        return 'Unknown';
    }
  }

  static IconData getStatusIcon(int? status) {
    switch (status) {
      case MemberGroup.active:
        return Icons.check_circle;
      case MemberGroup.pending:
        return Icons.hourglass_empty;
      case MemberGroup.inactive:
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  static Future<void> updateMemberGroupStatus({
    required String docId,
    required String userId,
    required String groupId,
    required int newStatus, 
    required MemberGroupService memberGroupService,
    required BuildContext context,
  }) async {
    try {
      memberGroupService.updateMemberGroupStatus(docId, newStatus);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status updated to ${getStatusText(newStatus)}'),
            backgroundColor: getStatusColor(newStatus),
          ),
        );

        AdminEditMemberGroupNotifications.updateMemberGroupStatus(
          userId: userId,
          groupId: groupId,
          status: newStatus,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update status'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}