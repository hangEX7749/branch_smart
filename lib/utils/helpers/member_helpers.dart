import 'package:branch_comm/model/member_model.dart';
import 'package:branch_comm/services/database/user_service.dart';
import 'package:flutter/material.dart';

class MemberHelpers {
  static Color getStatusColor(int? status) {
    switch (status) {
      case Member.active:
        return Colors.green;
      case Member.pending:
        return Colors.orange;
      case Member.inactive:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  static String getStatusText(int? status) {
    switch (status) {
      case Member.active:
        return 'Active';
      case Member.pending:
        return 'Pending';
      case Member.inactive:
        return 'Inactive';
      default:
        return 'Unknown';
    }
  }

  static IconData getStatusIcon(int? status) {
    switch (status) {
      case Member.active:
        return Icons.check_circle;
      case Member.pending:
        return Icons.hourglass_empty;
      case Member.inactive:
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  static Future<void> updateMemberStatus({
    required String docId,
    required int newStatus,
    required UserService userService,
    required BuildContext context,
  }) async {
    try {
      final proceed = await userService.updateMemberStatus(docId, newStatus);

      if (!proceed) {
        throw Exception('Failed to update member status');
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status updated to ${getStatusText(newStatus)}'),
            backgroundColor: getStatusColor(newStatus),
          ),
        );
        Navigator.of(context).pop();  
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating status: $e')),
        );
        Navigator.of(context).pop();  
      }
    }
  }
}