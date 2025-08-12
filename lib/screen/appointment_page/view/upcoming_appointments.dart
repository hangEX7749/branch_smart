import 'package:branch_comm/utils/helpers/appointment_helpers.dart';
import 'package:branch_comm/screen/account_page/utils/index.dart';
import 'package:branch_comm/services/database/appointment_service.dart';
import 'package:branch_comm/widgets/custom_appbar.dart';
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
        appBar: CustomAppBar(title: 'Upcoming Appointments'),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: const CustomAppBar(title: 'Upcoming Appointments'),
      body: StreamBuilder<QuerySnapshot>(
        stream: _appointmentService.getUserAppointments(userId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong.'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No upcoming appointments.'));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (_, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final date = (data['invite_datetime'] as Timestamp).toDate();
              final status = data['status'] as int?;
              final numGuests = data['num_guests'];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  leading: Icon(
                    AppointmentHelpers.getStatusIcon(status),
                    color: AppointmentHelpers.getStatusColor(status),
                    size: 32,
                  ),
                  title: Text(
                    data['guest_name'] ?? 'Unknown',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${data['venue']} • ${DateFormat('yyyy-MM-dd HH:mm').format(date)}",
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Status: ${AppointmentHelpers.getStatusText(status)}",
                        style: TextStyle(
                          color: AppointmentHelpers.getStatusColor(status),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (numGuests != null)
                        Text("Guests: $numGuests"),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );

  }
}
