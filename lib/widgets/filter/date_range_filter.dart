import 'package:branch_comm/utils/date/data_range.dart';
import 'package:flutter/material.dart';

class DateRangeFilterWidget extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(DateTime? startDate, DateTime? endDate) onDateRangeChanged;
  final bool showPresets;
  final bool showChips;
  final String? placeholder;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;

  const DateRangeFilterWidget({
    super.key,
    this.startDate,
    this.endDate,
    required this.onDateRangeChanged,
    this.showPresets = true,
    this.showChips = true,
    this.placeholder,
    this.padding,
    this.textStyle,
  });

  Future<void> _showDateRangePicker(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: startDate != null && endDate != null
          ? DateTimeRange(start: startDate!, end: endDate!)
          : null,
    );

    if (picked != null) {
      onDateRangeChanged(picked.start, picked.end);
    }
  }

  Future<void> _showStartDatePicker(BuildContext context) async {
    final DateTime? picked = await DateRangeUtils.showSingleDatePicker(
      context: context,
      initialDate: startDate,
      lastDate: endDate,
    );

    if (picked != null) {
      final validated = DateRangeUtils.validateDateRange(picked, endDate);
      onDateRangeChanged(validated['startDate'], validated['endDate']);
    }
  }

  Future<void> _showEndDatePicker(BuildContext context) async {
    final DateTime? picked = await DateRangeUtils.showSingleDatePicker(
      context: context,
      initialDate: endDate ?? startDate,
      firstDate: startDate,
    );

    if (picked != null) {
      final validated = DateRangeUtils.validateDateRange(startDate, picked);
      onDateRangeChanged(validated['startDate'], validated['endDate']);
    }
  }

  void _clearFilter() {
    onDateRangeChanged(null, null);
  }

  void _clearStartDate() {
    onDateRangeChanged(null, endDate);
  }

  void _clearEndDate() {
    onDateRangeChanged(startDate, null);
  }

  void _applyPreset(DateTimeRange range) {
    onDateRangeChanged(range.start, range.end);
  }

  List<PopupMenuEntry<String>> _buildMenuItems(BuildContext context) {
    final items = <PopupMenuEntry<String>>[
      const PopupMenuItem(
        value: 'range',
        child: ListTile(
          leading: Icon(Icons.date_range),
          title: Text('Select Date Range'),
          contentPadding: EdgeInsets.zero,
        ),
      ),
      const PopupMenuItem(
        value: 'start',
        child: ListTile(
          leading: Icon(Icons.calendar_month),
          title: Text('Set Start Date'),
          contentPadding: EdgeInsets.zero,
        ),
      ),
      const PopupMenuItem(
        value: 'end',
        child: ListTile(
          leading: Icon(Icons.event),
          title: Text('Set End Date'),
          contentPadding: EdgeInsets.zero,
        ),
      ),
    ];

    // Add presets if enabled
    if (showPresets) {
      items.add(const PopupMenuDivider());
      final presets = DateRangeUtils.getPresetRanges();
      for (final preset in presets.entries) {
        items.add(
          PopupMenuItem(
            value: 'preset_${preset.key}',
            child: ListTile(
              leading: const Icon(Icons.schedule),
              title: Text(preset.key),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        );
      }
    }

    // Add clear option if dates are set
    if (startDate != null || endDate != null) {
      items.add(const PopupMenuDivider());
      items.add(
        const PopupMenuItem(
          value: 'clear',
          child: ListTile(
            leading: Icon(Icons.clear),
            title: Text('Clear Filter'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      );
    }

    return items;
  }

  void _handleMenuSelection(String value, BuildContext context) {
    switch (value) {
      case 'range':
        _showDateRangePicker(context);
        break;
      case 'start':
        _showStartDatePicker(context);
        break;
      case 'end':
        _showEndDatePicker(context);
        break;
      case 'clear':
        _clearFilter();
        break;
      default:
        if (value.startsWith('preset_')) {
          final presetName = value.substring(7);
          final presets = DateRangeUtils.getPresetRanges();
          final preset = presets[presetName];
          if (preset != null) {
            _applyPreset(preset);
          }
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  DateRangeUtils.getDateRangeText(startDate, endDate),
                  style: textStyle ?? const TextStyle(fontSize: 16),
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.calendar_today),
                onSelected: (value) => _handleMenuSelection(value, context),
                itemBuilder: (context) => _buildMenuItems(context),
              ),
            ],
          ),
          // Show chips for selected dates
          if (showChips && (startDate != null || endDate != null))
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  if (startDate != null)
                    Chip(
                      label: Text('From: ${DateRangeUtils.formatDateShort(startDate!)}'),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: _clearStartDate,
                    ),
                  if (startDate != null && endDate != null)
                    const SizedBox(width: 8),
                  if (endDate != null)
                    Chip(
                      label: Text('To: ${DateRangeUtils.formatDateShort(endDate!)}'),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: _clearEndDate,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}