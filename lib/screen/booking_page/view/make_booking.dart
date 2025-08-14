import 'package:branch_comm/model/booking_model.dart';
import 'package:branch_comm/services/database/amenity_group_service.dart';
import 'package:branch_comm/services/database/amenity_service.dart';
import 'package:branch_comm/services/database/booking_service.dart';
import 'package:branch_comm/services/shared_pref.dart';
import 'package:branch_comm/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MakeBooking extends StatefulWidget {
  final String groupId;
  const MakeBooking({super.key, required this.groupId});

  @override
  State<MakeBooking> createState() => _MakeBookingState();
}

class _MakeBookingState extends State<MakeBooking> {
  String? name, id, email, amenityId, groupId;
  int? numGuests = 1;
  String? selectedAmenity;
  DateTime? selectedDate;
  String? selectedTime;
  int? maxGuests; // Store the max capacity for selected amenity

  // Cache the amenities list to prevent unnecessary rebuilds
  List<Map<String, dynamic>>? _cachedAmenities;
  
  // Controllers for form fields
  final TextEditingController _guestController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  final BookingService _bookingService = BookingService();
  final AmenityService _amenityService = AmenityService();
  
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
        groupId = widget.groupId;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _loadAmenities() async {
    if (_cachedAmenities != null) {
      return _cachedAmenities!;
    }

    final snapshot = await AmenityGroupService().getAmenityGroupByGroupId(widget.groupId);
    
    if (snapshot.docs.isEmpty) {
      _cachedAmenities = [];
      return _cachedAmenities!;
    }

    final amenities = await Future.wait(
      snapshot.docs.map((doc) async {
        final data = doc.data();
        final amenityId = data['amenity_id'] as String;
        
        // Get full amenity details including max_capacity
        final amenityDoc = await _amenityService.getAmenityById(amenityId);
        final amenityData = amenityDoc;
        
        final amenityName = amenityData?['amenity_name'] ?? amenityId;
        final maxCapacity = amenityData?['max_capacity'] as int? ?? 1;
        
        return {
          'id': amenityId,
          'amenity_name': amenityName,
          'max_capacity': maxCapacity,
        };
      }),
    );
    _cachedAmenities = amenities;
    return _cachedAmenities!;
  }

  @override
  void initState() {
    super.initState();
    getTheSharedPref();
    _guestController.text = numGuests.toString();
  }

  @override
  void dispose() {
    _guestController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: const CustomAppBar(title: 'Book Facility'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Amenity Selection
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _loadAmenities(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Text('Failed to load amenities');
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('No amenities available');
                }

                final amenities = snapshot.data!;

                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Select Amenity'),
                  value: selectedAmenity,
                  items: amenities
                      .map((e) => DropdownMenuItem<String>(
                            value: e['id'] as String,
                            child: Text('${e['amenity_name']} (Max: ${e['max_capacity']} guests)'),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedAmenity = value;
                      // Set maxGuests for the selected amenity
                      maxGuests = amenities.firstWhere(
                        (amenity) => amenity['id'] == value,
                        orElse: () => {'max_capacity': 1},
                      )['max_capacity'] as int;
                      
                      // Reset guests if current selection exceeds max
                      if (numGuests != null && numGuests! > maxGuests!) {
                        numGuests = maxGuests;
                        _guestController.text = maxGuests.toString();
                      }
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            
            // Date Selection
            TextFormField(
              controller: _dateController,
              readOnly: true,
              decoration: const InputDecoration(labelText: 'Select Date'),
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
                    _dateController.text = "${picked.day}/${picked.month}/${picked.year}";
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            
            // Guest Number Input - Fixed to prevent rebuilds
            TextFormField(
              controller: _guestController,
              decoration: InputDecoration(
                labelText: maxGuests != null 
                    ? 'Number of Guests (Max: $maxGuests)'
                    : 'Number of Guests',
                helperText: maxGuests != null 
                    ? 'Maximum $maxGuests guests allowed'
                    : null,
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                // Allow empty field while user is typing
                if (value.isEmpty) {
                  numGuests = null;
                  return;
                }
                
                final parsedValue = int.tryParse(value);
                if (parsedValue != null && parsedValue > 0) {
                  // Check against max capacity if available
                  if (maxGuests != null && parsedValue > maxGuests!) {
                    // Don't allow more than max capacity
                    _guestController.text = maxGuests.toString();
                    _guestController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _guestController.text.length),
                    );
                    numGuests = maxGuests;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Maximum $maxGuests guests allowed for this amenity'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  } else {
                    numGuests = parsedValue;
                  }
                } else {
                  // Don't modify the controller text while user is typing
                  numGuests = null;
                }
              },
              onEditingComplete: () {
                // Only validate and set default when user finishes editing
                if (_guestController.text.isEmpty || numGuests == null || numGuests! <= 0) {
                  _guestController.text = '1';
                  numGuests = 1;
                }
              },
            ),
            const SizedBox(height: 16),
            
            // Time Selection
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
            
            // Confirm Button
            ElevatedButton(
              onPressed: () async {
                // Validate numGuests before proceeding
                if (_guestController.text.isEmpty || numGuests == null || numGuests! <= 0) {
                  _guestController.text = '1';
                  numGuests = 1;
                }
                
                if (selectedAmenity != null &&
                    selectedDate != null &&
                    selectedTime != null &&
                    numGuests != null &&
                    numGuests! > 0 &&
                    id != null) {
                  final dateOnly = DateTime(
                    selectedDate!.year,
                    selectedDate!.month,
                    selectedDate!.day,
                  ).toIso8601String().split('T')[0];

                  try {
                    final query = await _bookingService.checkBooking(
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
                    
                    Map<String, dynamic> bookingMap = {
                      'id': await _bookingService.getNewId(),
                      'group_id': widget.groupId,
                      'amenity_id': selectedAmenity!,
                      'num_guests': numGuests,
                      'user_id': id,
                      'date': dateOnly,
                      'time': selectedTime,
                      'status': Booking.pending, 
                      'created_at': FieldValue.serverTimestamp(),
                      'updated_at': FieldValue.serverTimestamp(),
                    };

                    final proceed = await _bookingService.addBooking(bookingMap, bookingMap['id']);
                    
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

                    // Reset form
                    setState(() {
                      numGuests = 1;
                      selectedAmenity = null;
                      selectedDate = null;
                      selectedTime = null;
                      maxGuests = null; // Reset max guests
                    });
                    _guestController.text = '1';
                    _dateController.clear();
                    
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
          ],
        ),
      ),
    );
  }
}