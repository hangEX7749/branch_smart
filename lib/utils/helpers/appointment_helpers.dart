import 'package:flutter/material.dart';
import 'package:branch_comm/model/appointment_model.dart';

class AppointmentHelpers {
  static Color getStatusColor(int? status) {
    switch (status) {
      case Appointment.completed:
        return Colors.green;
      case Appointment.pending:
        return Colors.orange;
      case Appointment.rejected:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  static String getStatusText(int? status) {
    switch (status) {
      case Appointment.completed:
        return 'Completed';
      case Appointment.pending:
        return 'Pending';
      case Appointment.rejected:
        return 'Rejected';
      default:
        return 'Unknown';
    }
  }

  static IconData getStatusIcon(int? status) {
    switch (status) {
      case Appointment.completed:
        return Icons.check_circle;
      case Appointment.pending:
        return Icons.hourglass_empty;
      case Appointment.rejected:
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }
}