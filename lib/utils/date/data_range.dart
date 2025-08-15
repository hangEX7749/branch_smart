// utils/date_range_utils.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateRangeUtils {
  /// Formats a date to YYYY-MM-DD string
  static String formatDateToString(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  /// Formats a date to a readable format (e.g., "Jan 15, 2024")
  static String formatDateReadable(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  /// Formats a date to short format (e.g., "Jan 15")
  static String formatDateShort(DateTime date) {
    return DateFormat('MMM dd').format(date);
  }

  /// Gets display text for date range
  static String getDateRangeText(DateTime? startDate, DateTime? endDate) {
    if (startDate == null && endDate == null) {
      return "No date range selected";
    } else if (startDate != null && endDate != null) {
      return "${formatDateReadable(startDate)} - ${formatDateReadable(endDate)}";
    } else if (startDate != null) {
      return "From: ${formatDateReadable(startDate)}";
    } else {
      return "Until: ${formatDateReadable(endDate!)}";
    }
  }

  /// Checks if a date falls within the specified range
  static bool isDateInRange(DateTime dateToCheck, DateTime? startDate, DateTime? endDate) {
    if (startDate == null && endDate == null) return true;
    
    final dateOnly = DateTime(dateToCheck.year, dateToCheck.month, dateToCheck.day);
    
    if (startDate != null && endDate != null) {
      final start = DateTime(startDate.year, startDate.month, startDate.day);
      final end = DateTime(endDate.year, endDate.month, endDate.day);
      return dateOnly.isAfter(start.subtract(const Duration(days: 1))) && 
             dateOnly.isBefore(end.add(const Duration(days: 1)));
    } else if (startDate != null) {
      final start = DateTime(startDate.year, startDate.month, startDate.day);
      return dateOnly.isAfter(start.subtract(const Duration(days: 1)));
    } else if (endDate != null) {
      final end = DateTime(endDate.year, endDate.month, endDate.day);
      return dateOnly.isBefore(end.add(const Duration(days: 1)));
    }
    
    return true;
  }

  /// Shows date range picker dialog
  static Future<DateTimeRange?> showDateRangePicker({
    required BuildContext context,
    DateTimeRange? initialDateRange,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    return await showDateRangePicker(
      context: context,
      firstDate: firstDate ?? DateTime(2020),
      lastDate: lastDate ?? DateTime(2100),
      initialDateRange: initialDateRange,
    );
  }

  /// Shows single date picker dialog
  static Future<DateTime?> showSingleDatePicker({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    return await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(2020),
      lastDate: lastDate ?? DateTime(2100),
    );
  }

  /// Validates date range (ensures start is not after end)
  static Map<String, DateTime?> validateDateRange(DateTime? startDate, DateTime? endDate) {
    DateTime? validStartDate = startDate;
    DateTime? validEndDate = endDate;

    // If both dates are set and start is after end, clear the conflicting one
    if (startDate != null && endDate != null && startDate.isAfter(endDate)) {
      // Clear the end date to allow user to set a new valid end date
      validEndDate = null;
    }

    return {
      'startDate': validStartDate,
      'endDate': validEndDate,
    };
  }

  /// Gets preset date ranges (Today, This Week, This Month, etc.)
  static Map<String, DateTimeRange> getPresetRanges() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return {
      'Today': DateTimeRange(start: today, end: today),
      'This Week': DateTimeRange(
        start: today.subtract(Duration(days: now.weekday - 1)),
        end: today.add(Duration(days: 7 - now.weekday)),
      ),
      'This Month': DateTimeRange(
        start: DateTime(now.year, now.month, 1),
        end: DateTime(now.year, now.month + 1, 0),
      ),
      'Next 7 Days': DateTimeRange(
        start: today,
        end: today.add(const Duration(days: 7)),
      ),
      'Next 30 Days': DateTimeRange(
        start: today,
        end: today.add(const Duration(days: 30)),
      ),
    };
  }
}