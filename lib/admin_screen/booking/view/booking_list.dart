import 'package:branch_comm/mixins/name_fetching_mixin.dart';
import 'package:branch_comm/services/database/amenity_service.dart';
import 'package:branch_comm/services/database/booking_service.dart';
import 'package:branch_comm/model/booking_model.dart';
import 'package:branch_comm/services/database/group_service.dart';
import 'package:branch_comm/services/database/user_service.dart';
import 'package:branch_comm/utils/helpers/booking_helpers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookingList extends StatefulWidget {
  const BookingList({super.key});

  @override
  State<BookingList> createState() => _BookingListState();
}

class _BookingListState extends State<BookingList> with NameFetchingMixin{
  final GroupService _groupService = GroupService();
  final BookingService _bookingService = BookingService(); 
  final AmenityService _amenityService = AmenityService();
  final UserService _userService = UserService();
  String selectedStatus = 'All';

  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  final TextEditingController _dateRangeController = TextEditingController();
  
  @override
  UserService get userService => _userService;
  @override
  GroupService get groupService => _groupService;
  @override
  AmenityService get amenityService => _amenityService;

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
              decoration: InputDecoration(
                labelText: 'Filter by Date Range',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _pickDateRange,
                ),
                border: const OutlineInputBorder(),
              ),
              readOnly: true,
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

                final bookings = snapshot.data!.docs.map((doc) {
                  return doc;
                }).toList(); 

                // Apply status filter if selected
                final filteredBookings = bookings.where((doc) {
                  final booking = doc.data() as Map<String, dynamic>;
                  final status = booking['status'] as int?;
                  return selectedStatus == Booking.allStatusLabel ||
                         status == Booking.statusFilterOptions[selectedStatus];
                }).toList();

                if (filteredBookings.isEmpty) {
                  return const Center(child: Text("No bookings match the selected filters"));
                }

                // Apply date range filter if selected
                if (_selectedStartDate != null && _selectedEndDate != null) {
                  filteredBookings.retainWhere((doc) {
                    final booking = doc.data() as Map<String, dynamic>;
                    final date = booking['date'] as Timestamp?;
                    if (date == null) return false;
                    final bookingDate = date.toDate();
                    return bookingDate.isAfter(_selectedStartDate!) &&
                           bookingDate.isBefore(_selectedEndDate!);
                  });
                }

                return ListView.builder(
                  itemCount: filteredBookings.length,
                  itemBuilder: (_, index) {
                    final booking = filteredBookings[index];

                    //Get values from booking helper
                    final status = booking['status'] as int?;
                    final statusColor = BookingHelpers.getStatusColor(status);
                    final statusText = BookingHelpers.getStatusText(status); 
                    final statusIcon = BookingHelpers.getStatusIcon(status);

                    return ListTile(
                      leading: Icon(statusIcon, color: statusColor),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FutureBuilder<String>(
                            future: getAmenityName(booking['amenity_id']),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Text('Loading amenity...');
                              }
                              if (snapshot.hasError) {
                                return const Text('Error loading amenity');
                              }
                              return Text(snapshot.data ?? 'Unknown Amenity');
                            },
                          ),
                          const SizedBox(width: 8),
                          FutureBuilder<String>(
                            future: getGroupName(booking['group_id']),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Text('Loading group...');
                              }
                              return Text(
                                snapshot.data ?? 'Unknown group'
                              );
                            },
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FutureBuilder<String>(
                            future: getUserName(booking['user_id']),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Text('Loading user...');
                              }
                              return Text(
                                "Booked by: ${snapshot.data ?? 'Unknown User'}"
                              );
                            },
                          ),
                          Text("Date: ${booking['date']}"),
                          Row(
                            children: [
                              Icon(statusIcon, size: 16, color: statusColor),
                              const SizedBox(width: 4),
                              Text(
                                statusText,
                                style: TextStyle(color: statusColor, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ],
                      ),
                      isThreeLine: true,
                      trailing: PopupMenuButton<String>(
                        onSelected: (val) => _updateStatus(booking['id'], val),
                        itemBuilder: (BuildContext context) => [
                          PopupMenuItem<String>(
                            value: Booking.pending.toString(),
                            child: Row(
                              children: [
                                Icon(
                                  BookingHelpers.getStatusIcon(Booking.pending),
                                  color: BookingHelpers.getStatusColor(Booking.pending),
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(BookingHelpers.getStatusText(Booking.pending)),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: Booking.completed.toString(),
                            child: Row(
                              children: [
                                Icon(
                                  BookingHelpers.getStatusIcon(Booking.completed),
                                  color: BookingHelpers.getStatusColor(Booking.completed),
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(BookingHelpers.getStatusText(Booking.completed)),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: Booking.rejected.toString(),
                            child: Row(
                              children: [
                                Icon(
                                  BookingHelpers.getStatusIcon(Booking.rejected),
                                  color: BookingHelpers.getStatusColor(Booking.rejected),
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(BookingHelpers.getStatusText(Booking.rejected)),
                              ],
                            ),
                          ),
                        ],
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

  // Update status of an bookings
  Future<void> _updateStatus(String docId, String newStatus) async {
    final status = int.tryParse(newStatus);
    if (status == null) return;

    try {
      await _bookingService.updateBookingStatus(docId, status);
          
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Status updated to ${Booking.codeToName(status)}"),
          backgroundColor: BookingHelpers.getStatusColor(status)
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to update status"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      currentDate: DateTime.now(),
      saveText: 'Apply',
    );

    if (picked != null) {
      setState(() {
        _selectedStartDate = picked.start;
        _selectedEndDate = picked.end;
        _dateRangeController.text = 
          '${DateFormat('MMM d').format(picked.start)} - '
          '${DateFormat('MMM d, y').format(picked.end)}';
      });
    }
  }
}