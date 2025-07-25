import 'package:branch_comm/screen/appointment_page/view/invite_guest.dart';
import 'package:branch_comm/screen/appointment_page/view/past_appointments.dart';
import 'package:branch_comm/screen/appointment_page/view/upcoming_appointments.dart';
import 'package:flutter/material.dart';

class Appointment extends StatefulWidget {
  const Appointment({super.key});
  @override
  State<Appointment> createState() => _AppointmentState();
}

class _AppointmentState extends State<Appointment> {
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Appointment')),
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
              MaterialPageRoute(builder: (_) => const InviteGuest()),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.event_available),
            title: const Text('Upcoming Appointments'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UpcomingAppointments()),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Past Appointments'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PastAppointments()),
            ),
          ),
          const Divider()
        ],
      ),
    );
  }
  
}
