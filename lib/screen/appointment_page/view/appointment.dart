import 'package:branch_comm/screen/appointment_page/view/invite_guest.dart';
import 'package:branch_comm/screen/appointment_page/view/past_appointments.dart';
import 'package:branch_comm/screen/appointment_page/view/upcoming_appointments.dart';
import 'package:branch_comm/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';

class Appointment extends StatefulWidget {
  final String groupId; // Optional, used for group appointments
  const Appointment({super.key, required this.groupId});
  @override
  State<Appointment> createState() => _AppointmentState();
}

class _AppointmentState extends State<Appointment> {
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: const CustomAppBar(title: 'Appointment'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person_add),
            title: const Text('Invite Guest'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => InviteGuest(groupId: widget.groupId)),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.event_available),
            title: const Text('Upcoming Appointments'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => UpcomingAppointments(groupId: widget.groupId)),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Past Appointments'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PastAppointments(groupId: widget.groupId)),
            ),
          ),
          const Divider()
        ],
      ),
    );
  }
  
}
