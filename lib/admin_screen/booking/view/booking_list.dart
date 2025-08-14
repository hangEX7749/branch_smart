import 'package:branch_comm/screen/booking_page/view/booking.dart';
import 'package:branch_comm/services/database/booking_service.dart';
import 'package:branch_comm/model/booking_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BookingList extends StatefulWidget {
  const BookingList({super.key});

  @override
  State<BookingList> createState() => _BookingListState();
}

class _BookingListState extends State<BookingList> {
  final BookingService _bookingService = BookingService(); 
  String selectedStatus = 'All';

  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  final TextEditingController _dateRangeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Bookings")),
      body: Column(
        children: [
          // Status filter dropdown
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: DropdownButtonFormField<String>(
              value: selectedStatus,
              items: Booking.statusFilterOptions.keys.map((label) {
                return DropdownMenuItem(
                  value: label,
                  child: Text(label),
                );
              }).toList(),
              onChanged: (value) => setState(
                () => selectedStatus = value ?? Booking.allStatusLabel
              ),
              decoration: const InputDecoration(
                labelText: 'Filter by Status',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          // Date range filter
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _dateRangeController,
              decoration: const InputDecoration(
                labelText: 'Filter by Date Range',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          //Bookings list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _bookingService.getAllBookings(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text("Something went wrong"));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No bookings found"));
                }

                final bookings = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final booking = bookings[index].data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        title: Text(booking['amenity'] ?? 'No Name'),
                        subtitle: Text(booking['date'] ?? 'No Date'),
                        // trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          // Add optional details navigation or dialog here
                        },
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
}