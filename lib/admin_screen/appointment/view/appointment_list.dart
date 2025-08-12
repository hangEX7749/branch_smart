import 'package:branch_comm/admin_screen/appointment/utils/appointment_helpers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:branch_comm/model/appointment_model.dart';
import 'package:branch_comm/services/database/appointment_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppointmentList extends StatefulWidget {
  const AppointmentList({super.key});

  @override
  State<AppointmentList> createState() => _AppointmentListState();
}

class _AppointmentListState extends State<AppointmentList> {
  final AppointmentService _appointmentService = AppointmentService();
  String selectedStatus = 'All';

  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  final TextEditingController _dateRangeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Appointments")),
      body: Column(
        children: [
          // Status filter dropdown
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: DropdownButtonFormField<String>(
              value: selectedStatus,
              items: Appointment.statusFilterOptions.keys.map((label) {
                return DropdownMenuItem(
                  value: label,
                  child: Text(label),
                );
              }).toList(),
              onChanged: (value) => setState(
                () => selectedStatus = value ?? Appointment.allStatusLabel
              ),
              decoration: const InputDecoration(
                labelText: 'Filter by Status',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _dateRangeController,
              decoration: InputDecoration(
                labelText: 'Date Range',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _pickDateRange,
                ),
                border: const OutlineInputBorder(),
              ),
              readOnly: true,
            ),
          ),
          // Appointments list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _appointmentService.getAllAppointments(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError || !snapshot.hasData) {
                  return const Center(child: Text("Failed to load appointments."));
                }

                // Convert documents to Appointment objects
                final appointments = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return Appointment(
                    id: doc.id,
                    groupId: data['group_id'],
                    userId: data['userId'] ?? '',
                    guestName: data['guest_name'],
                    contactNum: data['contact_number'],
                    venue: data['venue'] ?? 'Unknown venue',
                    numGuests: data['num_guests'] ?? 1,
                    appointmentType: data['appointment_type'] ?? Appointment.invite,
                    status: data['status'],
                    inviteDateTime: (data['invite_datetime'] as Timestamp).toDate(),
                    expiredDateTime: data['expired_datetime'] != null 
                        ? (data['expired_datetime'] as Timestamp).toDate() 
                        : null,
                    createdAt: (data['created_at'] as Timestamp?)?.toDate(),
                    updatedAt: (data['updated_at'] as Timestamp?)?.toDate(),
                  );
                }).toList();

                // Apply status filter if selected
                final filteredAppointments = selectedStatus == 'All'
                    ? appointments
                    : appointments.where((a) => a.status == Appointment.statusFilterOptions[selectedStatus]).toList();

                if (filteredAppointments.isEmpty) {
                  return const Center(child: Text("No appointments found."));
                }

                // Apply date range filter if selected
                if (_selectedStartDate != null && _selectedEndDate != null) {
                  filteredAppointments.retainWhere((appointment) {
                    return appointment.inviteDateTime != null &&
                        appointment.inviteDateTime!.isAfter(_selectedStartDate!) &&
                        appointment.inviteDateTime!.isBefore(_selectedEndDate!);
                  });
                }

                return ListView.builder(
                  itemCount: filteredAppointments.length,
                  itemBuilder: (_, index) {
                    final appointment = filteredAppointments[index];

                    // Get values from helper
                    final statusColor = AppointmentHelpers.getStatusColor(appointment.status);
                    final statusText = AppointmentHelpers.getStatusText(appointment.status);
                    final statusIcon = AppointmentHelpers.getStatusIcon(appointment.status);

                    return ListTile(
                      leading: Icon(Icons.calendar_today, color: Colors.blue),
                      title: Text(
                        "${appointment.guestName ?? 'No name'} @ ${appointment.venue}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Date: ${DateFormat('yyyy-MM-dd HH:mm').format(appointment.inviteDateTime!)}"),
                          Row(
                            children: [
                              Icon(statusIcon, size: 16, color: statusColor),
                              const SizedBox(width: 4),
                              Text(
                                statusText,
                                style: TextStyle(color: statusColor, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          if (appointment.numGuests != null) 
                            Text("Guests: ${appointment.numGuests}"),
                        ],
                      ),
                      isThreeLine: true,
                      trailing: PopupMenuButton<String>(
                        onSelected: (val) => _updateStatus(appointment.id, val),
                        itemBuilder: (BuildContext context) => [
                          PopupMenuItem<String>(
                            value: Appointment.pending.toString(),
                            child: Row(
                              children: [
                                Icon(
                                  AppointmentHelpers.getStatusIcon(Appointment.pending),
                                  color: AppointmentHelpers.getStatusColor(Appointment.pending),
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(AppointmentHelpers.getStatusText(Appointment.pending)),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: Appointment.completed.toString(),
                            child: Row(
                              children: [
                                Icon(
                                  AppointmentHelpers.getStatusIcon(Appointment.completed),
                                  color: AppointmentHelpers.getStatusColor(Appointment.completed),
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(AppointmentHelpers.getStatusText(Appointment.completed)),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: Appointment.rejected.toString(),
                            child: Row(
                              children: [
                                Icon(
                                  AppointmentHelpers.getStatusIcon(Appointment.rejected),
                                  color: AppointmentHelpers.getStatusColor(Appointment.rejected),
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(AppointmentHelpers.getStatusText(Appointment.rejected)),
                              ],
                            ),
                          ),
                        ],
                      ),

                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Update status of an appointment
  Future<void> _updateStatus(String docId, String newStatus) async {
    final status = int.tryParse(newStatus);
    if (status == null) return;

    try {
      await _appointmentService.updateAppointmentStatus(docId, status);
          
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Status updated to ${Appointment.codeToName(status)}"),
          backgroundColor: AppointmentHelpers.getStatusColor(status)
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to update status"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      currentDate: DateTime.now(),
      saveText: 'Apply',
    );

    if (picked != null) {
      setState(() {
        _selectedStartDate = picked.start;
        _selectedEndDate = picked.end;
        _dateRangeController.text = 
          '${DateFormat('MMM d').format(picked.start)} - '
          '${DateFormat('MMM d, y').format(picked.end)}';
      });
    }
  }
}