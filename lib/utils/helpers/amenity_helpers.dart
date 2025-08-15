import 'package:flutter/material.dart';
import 'package:branch_comm/model/amenity_model.dart';

class AmenityHelpers {
    static Color getStatusColor(int? status) {
    switch (status) {
      case Amenity.active:
        return Colors.green;
      case Amenity.inactive:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  static String getStatusText(int? status) {
    switch (status) {
      case Amenity.active:
        return 'active';
      case Amenity.inactive:
        return 'inactive';
      default:
        return 'Unknown';
    }
  }

  static IconData getStatusIcon(int? status) {
    switch (status) {
      case Amenity.active:
        return Icons.check_circle;
      case Amenity.inactive:
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }
}