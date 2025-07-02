import 'package:branch_comm/services/database/booking_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:branch_comm/services/shared_pref.dart';

class ViewConfirmedBookingsPage extends StatefulWidget {
  const ViewConfirmedBookingsPage({super.key});

  @override
  State<ViewConfirmedBookingsPage> createState() => _ViewConfirmedBookingsPageState();
}

class _ViewConfirmedBookingsPageState extends State<ViewConfirmedBookingsPage> {
  DateTime? filterDate;
  String? name, userId, email;
  final BookingService bookingService = BookingService();
  
  Future<void> getTheSharedPref() async {
    final user = await SharedpreferenceHelper().getUser();

    if (!mounted) return;

    if (user.id.isEmpty || user.name.isEmpty) {
      Navigator.pushReplacementNamed(context, '/signin');
    } else {
      setState(() {
        userId = user.id;
        name = user.name;
        email = user.email;
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
    final formattedFilterDate = filterDate != null
        ? "${filterDate!.year}-${filterDate!.month.toString().padLeft(2, '0')}-${filterDate!.day.toString().padLeft(2, '0')}"
        : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Confirmed Bookings')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    filterDate == null
                        ? "No date selected"
                        : formattedFilterDate!,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() => filterDate = picked);
                    }
                  },
                ),
                if (filterDate != null)
                  TextButton(
                    onPressed: () {
                      setState(() => filterDate = null);
                    },
                    child: const Text("Clear"),
                  ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: bookingService.getUserBookings(userId ?? ''),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  //print('Error loading bookings: ${snapshot.error}');
                  return const Center(child: Text('Error loading bookings.'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No confirmed bookings found.'));
                }

                final docs = snapshot.data!.docs.where((doc) {
                  if (filterDate == null) return true;
                  final docDate = doc['date'];
                  return docDate == formattedFilterDate;
                }).toList();

                if (docs.isEmpty) {
                  return const Center(child: Text('No confirmed bookings found for selected date.'));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final booking = docs[index].data() as Map<String, dynamic>;
                    return ListTile(
                      leading: const Icon(Icons.check_circle, color: Colors.green),
                      title: Text(booking['amenity'] ?? 'Unknown'),
                      subtitle: Text("Date: ${booking['date']} • Time: ${booking['time']}"),
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
}
