import 'package:branch_comm/screen/account_page/utils/index.dart';
import 'package:branch_comm/services/database/appointment_service.dart';
import 'package:intl/intl.dart';

class UpcomingAppointments extends StatefulWidget {
  const UpcomingAppointments({super.key});

  @override
  State<UpcomingAppointments> createState() => _UpcomingAppointmentsState();
}

class _UpcomingAppointmentsState extends State<UpcomingAppointments> {
  String? userId;

  final AppointmentService _appointmentService = AppointmentService();

  Future<void> _loadUserId() async {
    final user = await SharedpreferenceHelper().getUser();
    if (mounted) {
      setState(() {
        userId = user.id;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Upcoming Appointments')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Upcoming Appointments')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _appointmentService.getUserAppointments(userId!),
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong.'));
          }

          // Check if the snapshot has data
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No upcoming appointments.'));
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No upcoming appointments.'));
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (_, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final date = (data['invite_datetime'] as Timestamp).toDate();
              return ListTile(
                title: Text(data['guest_name']),
                subtitle: Text("${data['venue']} • ${DateFormat('yyyy-MM-dd HH:mm').format(date)}"),
              );
            },
          );
        },
      ),
    );
  }
}
