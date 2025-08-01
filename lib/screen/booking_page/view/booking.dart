import 'package:branch_comm/screen/booking_page/view/view_booking.dart';
import 'package:branch_comm/services/database/booking_service.dart';
import 'package:branch_comm/services/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:random_string/random_string.dart';

class Booking extends StatefulWidget {
  const Booking({super.key});

  @override
  State<Booking> createState() => _BookingState();
}

class _BookingState extends State<Booking> {
  String? name, id, email;
  String? selectedAmenity;
  DateTime? selectedDate;
  String? selectedTime;

  final BookingService bookingService = BookingService();
  final List<String> amenities = ['Badminton Court', 'BBQ Area'];
  final List<String> timeSlots = ['9:00 AM', '11:00 AM', '2:00 PM', '5:00 PM'];

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
      appBar: AppBar(title: const Text('Book Facility')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Select Amenity'),
              value: selectedAmenity,
              items: amenities
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) {
                setState(() => selectedAmenity = value);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              readOnly: true,
              decoration: const InputDecoration(labelText: 'Select Date'),
              controller: TextEditingController(
                text: selectedDate == null
                    ? ''
                    : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
              ),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                );
                if (picked != null) {
                  setState(() => selectedDate = picked);
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Select Time Slot'),
              value: selectedTime,
              items: timeSlots
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) {
                setState(() => selectedTime = value);
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                if (selectedAmenity != null &&
                    selectedDate != null &&
                    selectedTime != null &&
                    id != null) {
                  final dateOnly = DateTime(
                    selectedDate!.year,
                    selectedDate!.month,
                    selectedDate!.day,
                  ).toIso8601String().split('T')[0]; // e.g., 2025-06-18

                  try {
                    final query = await bookingService.checkBooking(
                      selectedAmenity!,
                      dateOnly,
                      selectedTime!,
                    );

                    if (!context.mounted) return;

                    if (query.docs.isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                          '$selectedAmenity is already booked on ${selectedDate!.day}/${selectedDate!.month} at $selectedTime.',
                        ),
                      ));
                      return;
                    }

                    String bookingId = randomMerge('book_', randomAlphaNumeric(10));
                    
                    // New booking data
                    Map<String, dynamic> bookingMap = {
                      'user_id': id,
                      'amenity': selectedAmenity,
                      'date': dateOnly,
                      'time': selectedTime,
                      'status': 50, 
                      'created_at': FieldValue.serverTimestamp(),
                      'updated_at': FieldValue.serverTimestamp(),
                    };

                    final proceed = await bookingService.addBooking(bookingMap, bookingId);
                    
                    if (!context.mounted) return;

                    if (!proceed) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Booking failed. Try again.'),
                        ),
                      );
                      return;
                    }
                   
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                        'Booked $selectedAmenity on ${selectedDate!.day}/${selectedDate!.month} at $selectedTime',
                      ),
                    ));

                    setState(() {
                      selectedAmenity = null;
                      selectedDate = null;
                      selectedTime = null;
                    });
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Booking failed. Try again.'),
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Please complete all fields'),
                  ));
                }
              },
              child: const Text('Confirm Booking'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.lightBlue[800]
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ViewConfirmedBookingsPage(),
                  ),
                );
              },
              child: const Text('View Confirmed Bookings'),
            ),
          ],
        ),
      ),
    );
  }
}
