import 'package:branch_comm/screen/booking_page/view/make_booking.dart';
import 'package:branch_comm/screen/booking_page/view/past_booking.dart';
import 'package:branch_comm/screen/booking_page/view/view_booking.dart';
import 'package:branch_comm/services/shared_pref.dart';
import 'package:branch_comm/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';

class Booking extends StatefulWidget {
  final String groupId;
  const Booking({super.key, required this.groupId});

  @override
  State<Booking> createState() => _BookingState();
}

class _BookingState extends State<Booking> {
  String? name, id, email, groupId;
  String? selectedAmenity;
  DateTime? selectedDate;
  String? selectedTime;

  Future<void> getTheSharedPref() async {
    final user = await SharedpreferenceHelper().getUser();

    if (!mounted) return;

    if (user.id.isEmpty || user.name.isEmpty) {
      Navigator.pushReplacementNamed(context, '/signin');
    } else {
      setState(() {
        id = user.id;
        name = user.name;
        email = user.email;
        groupId = widget.groupId;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getTheSharedPref();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: const CustomAppBar(title: 'Book Facility'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person_add),
            title: const Text('Make Booking'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => MakeBooking(groupId: widget.groupId)),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.event_available),
            title: const Text('Upcoming Bookings'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => UpComingBookings(groupId: widget.groupId)),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Past Bookings'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PastBookings(groupId: widget.groupId)),
            ),
          ),
          const Divider()
        ],
      ),
    );
  }
}
