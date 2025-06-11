import 'package:branch_comm/services/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  final List<String> amenities = ['Badminton Court', 'BBQ Area'];
  final List<String> timeSlots = ['9:00 AM', '11:00 AM', '2:00 PM', '5:00 PM'];

  getTheSharedPref() async {
    name = await SharedpreferenceHelper().getUserName();
    id = await SharedpreferenceHelper().getUserId();
    email = await SharedpreferenceHelper().getUserEmail();

    if (id == null || name == null) {
      // User not logged in or prefs not set
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      setState(() {});
    }

    setState(() {
      
    });
  }

  @override
  void initState() {
    super.initState();
    getTheSharedPref();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Facility'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Amenity Dropdown
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Select Amenity'),
              value: selectedAmenity,
              items: amenities.map((e) {
                return DropdownMenuItem(value: e, child: Text(e));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedAmenity = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Date Picker
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
                  setState(() {
                    selectedDate = picked;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Time Slot Dropdown
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Select Time Slot'),
              value: selectedTime,
              items: timeSlots.map((e) {
                return DropdownMenuItem(value: e, child: Text(e));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedTime = value;
                });
              },
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: () async {
                if (selectedAmenity != null &&
                    selectedDate != null &&
                    selectedTime != null) {
                  final dateOnly = DateTime(
                    selectedDate!.year,
                    selectedDate!.month,
                    selectedDate!.day,
                  ).toIso8601String();

                  try {
                    // 1. Query for existing booking with same values
                    final query = await FirebaseFirestore.instance
                        .collection('bookings')
                        .where('amenity', isEqualTo: selectedAmenity)
                        .where('date', isEqualTo: dateOnly)
                        .where('time', isEqualTo: selectedTime)
                        .get();

                    if (query.docs.isNotEmpty) {
                      // 2. Duplicate exists
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                          '$selectedAmenity is already booked on ${selectedDate!.day}/${selectedDate!.month} at $selectedTime.',
                        ),
                      ));
                      return;
                    }

                    // 3. No duplicate, proceed to save
                    await FirebaseFirestore.instance.collection('bookings').add({
                      'amenity': selectedAmenity,
                      'date': dateOnly,
                      'time': selectedTime,
                      'createdAt': FieldValue.serverTimestamp(),
                    });

                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          'Booked $selectedAmenity on ${selectedDate!.day}/${selectedDate!.month} at $selectedTime'),
                    ));

                    // Clear form (optional)
                    setState(() {
                      selectedAmenity = null;
                      selectedDate = null;
                      selectedTime = null;
                    });
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Booking failed. Try again.')),
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

          ],
        ),
      ),
    );
  }
}
