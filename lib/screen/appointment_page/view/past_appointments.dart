import 'package:branch_comm/screen/account_page/utils/index.dart';
import 'package:branch_comm/services/database/appointment_service.dart';
import 'package:intl/intl.dart';

class PastAppointments extends StatefulWidget {
  const PastAppointments({super.key});

  @override
  State<PastAppointments> createState() => _PastAppointmentsState();
}

class _PastAppointmentsState extends State<PastAppointments> {
  String? userId;
  final AppointmentService _appointmentService = AppointmentService();

  Future<void> _loadUserId() async {
    final user = await SharedpreferenceHelper().getUser();
    if (mounted) {
      setState(() => userId = user.id);
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
        appBar: AppBar(title: const Text('Past Appointments')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Past Appointments')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _appointmentService.getPastAppointments(userId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong.'));
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text('No past appointments.'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (_, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final date = (data['invite_datetime'] as Timestamp).toDate();

              return ListTile(
                leading: const Icon(Icons.history, color: Colors.grey),
                title: Text(data['guest_name'] ?? 'Unknown'),
                subtitle: Text(
                  "${data['venue']} • ${DateFormat('yyyy-MM-dd HH:mm').format(date)}",
                ),
              );
            },
          );
        },
      ),
    );
  }
}
