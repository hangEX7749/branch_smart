import 'package:flutter/material.dart';
import 'package:branch_comm/model/booking_model.dart';

class BookingHelpers {
  static Color getStatusColor(int? status) {
    switch (status) {
      case Booking.completed:
        return Colors.green;
      case Booking.pending:
        return Colors.orange;
      case Booking.rejected:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  static String getStatusText(int? status) {
    switch (status) {
      case Booking.completed:
        return 'Completed';
      case Booking.pending:
        return 'Pending';
      case Booking.rejected:
        return 'Rejected';
      default:
        return 'Unknown';
    }
  }

  static IconData getStatusIcon(int? status) {
    switch (status) {
      case Booking.completed:
        return Icons.check_circle;
      case Booking.pending:
        return Icons.hourglass_empty;
      case Booking.rejected:
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  //get group name from group id
  static String getGroupName(String groupId) {
    // This is a placeholder. You would typically fetch the group name from a database or service.
    // For now, we return a dummy name.
    return 'Group Name for $groupId';
  }
}