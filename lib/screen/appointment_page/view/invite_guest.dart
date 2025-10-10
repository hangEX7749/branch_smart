import 'package:branch_comm/model/appointment_model.dart';
import 'package:branch_comm/services/notification.dart';
import 'package:branch_comm/services/shared_pref.dart';
import 'package:branch_comm/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:branch_comm/services/database/appointment_service.dart';
import 'package:intl/intl.dart';

class InviteGuest extends StatefulWidget {
  final String groupId;
  const InviteGuest({super.key, required this.groupId});

  @override
  State<InviteGuest> createState() => _InviteGuestState();
}

class _InviteGuestState extends State<InviteGuest> {

  final AppointmentService _appointmentService = AppointmentService();

  final _formKey = GlobalKey<FormState>();
  final _guestNameController = TextEditingController();
  final _guestNumController = TextEditingController();
  final _contactController = TextEditingController();
  final _venueController = TextEditingController();

  DateTime? selectedDateTime;
  String? userId, groupId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final user = await SharedpreferenceHelper().getUser();
    if (mounted) {
      setState(() {
        userId = user.id;
        groupId = widget.groupId;
      });
    }
  }

  Future<void> _sendInvitation() async {
    if (!_formKey.currentState!.validate() || selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and pick a date.')),
      );
      return;
    }

    try {
      //Check if appointment already exists
      if (await _appointmentService.appointmentExists(
          userId: userId!,
          groupId: groupId!,
          inviteDateTime: selectedDateTime!)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An appointment already exists for this date.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final now = DateTime.now();

      final appointmentMap = {
        'id': await _appointmentService.getNewId(),
        'group_id': groupId,
        'guest_name': _guestNameController.text.trim(),
        'contact_num': _contactController.text.trim(),
        'user_id': userId,
        'venue': _venueController.text.trim(),
        'num_guests': int.tryParse(_guestNumController.text.trim()) ?? 0, 
        'appointment_type': Appointment.invite, // 10 = Invite
        'status': Appointment.pending, // 30 = Pending
        'invite_datetime': selectedDateTime,
        'expired_datetime': selectedDateTime!.add(const Duration(hours: 2)),
        'created_at': now,
        'updated_at': now,
      };

      final proceed = await _appointmentService.addAppointment(appointmentMap, appointmentMap['id'] as String);

      if (mounted) {
        await AppointmentNotifications.onAppointmentCreated(
          context: context,
          userId: userId!,
          groupId: widget.groupId,
          //appointmentDetails: '$appointmentType on ${DateFormat('MMM dd').format(selectedDate)}',
        );
      }

      if (!mounted) return;

      if (!proceed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send invitation. Try again.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Guest invited successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Reset form
      _formKey.currentState!.reset();
      setState(() => selectedDateTime = null);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to invite guest.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = selectedDateTime != null
        ? DateFormat('yyyy-MM-dd HH:mm').format(selectedDateTime!)
        : 'Select Date & Time';

    return Scaffold(
      appBar: CustomAppBar(title: 'Invite Guest'),
      body: userId == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _guestNameController,
                      decoration: const InputDecoration(labelText: 'Guest Name'),
                      validator: (value) =>
                          value == null || value.trim().isEmpty ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: _contactController,
                      decoration: const InputDecoration(labelText: 'Contact Number'),
                      keyboardType: TextInputType.phone,
                      validator: (value) =>
                          value == null || value.trim().isEmpty ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: _venueController,
                      decoration: const InputDecoration(labelText: 'Venue'),
                      validator: (value) =>
                          value == null || value.trim().isEmpty ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: _guestNumController,
                      decoration: const InputDecoration(labelText: 'Number of Guests'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        final numGuests = int.tryParse(value);
                        if (numGuests == null || numGuests <= 0) {
                          return 'Must be a positive number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    ListTile(
                      title: Text(formattedDate),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().add(const Duration(days: 1)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 30)),
                        );

                        if (date != null) {
                          final time = await showTimePicker(
                            // ignore: use_build_context_synchronously
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );

                          if (time != null) {
                            setState(() {
                              selectedDateTime = DateTime(
                                date.year,
                                date.month,
                                date.day,
                                time.hour,
                                time.minute,
                              );
                            });
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _sendInvitation,
                      child: const Text('Send Invitation'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
