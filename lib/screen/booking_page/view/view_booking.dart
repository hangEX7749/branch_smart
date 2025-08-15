import 'package:branch_comm/utils/date/data_range.dart';
import 'package:branch_comm/widgets/filter/date_range_filter.dart';
import 'package:branch_comm/services/database/amenity_service.dart';
import 'package:branch_comm/services/database/booking_service.dart';
import 'package:branch_comm/services/database/group_service.dart';
import 'package:branch_comm/services/database/user_service.dart';
import 'package:branch_comm/utils/helpers/booking_helpers.dart';
import 'package:branch_comm/widgets/custom_appbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:branch_comm/services/shared_pref.dart';
import 'package:branch_comm/mixins/name_fetching_mixin.dart';

class UpComingBookings extends StatefulWidget {
  final String? groupId;
  const UpComingBookings({super.key, this.groupId});

  @override
  State<UpComingBookings> createState() => _UpComingBookingsState();
}

class _UpComingBookingsState extends State<UpComingBookings> with NameFetchingMixin {
  DateTime? startDate;
  DateTime? endDate;
  DateTime? filterDate;
  String? name, userId, email, groupId;

  final BookingService bookingService = BookingService();
  final UserService _userService = UserService();
  final GroupService _groupService = GroupService();
  final AmenityService _amenityService = AmenityService();

  @override
  UserService get userService => _userService;
  @override
  GroupService get groupService => _groupService;
  @override
  AmenityService get amenityService => _amenityService;

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
        groupId = widget.groupId;
      });
    }
  }

  void _onDateRangeChanged(DateTime? start, DateTime? end) {
    setState(() {
      startDate = start;
      endDate = end;
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
      appBar: CustomAppBar (title:'Upcoming Bookings'),
      body: Column(
        children: [
          DateRangeFilterWidget(
            startDate: startDate,
            endDate: endDate,
            onDateRangeChanged: _onDateRangeChanged,
            showPresets: true,
            showChips: true,
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: bookingService.getUserBookings(userId, groupId),
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
                  final data = doc.data() as Map<String, dynamic>;
                  final dateString = data['date'] as String;
                  final appointmentDate = DateTime.parse(dateString); // Parse the string
                  return DateRangeUtils.isDateInRange(appointmentDate, startDate, endDate);
                }).toList();

                if (docs.isEmpty) {
                  return const Center(child: Text('No confirmed bookings found for selected date.'));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final booking = docs[index].data() as Map<String, dynamic>;
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.check_circle, color: Colors.green),
                        title: Row(
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
                                return Text("${snapshot.data ?? 'Unknown Amenity'} @ ");
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
                            //status
                            Text(
                              "Status: ${BookingHelpers.getStatusText(booking['status'])}",
                              style: TextStyle(
                                color: BookingHelpers.getStatusColor(booking['status']),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Date: ${booking['date']} • Time: ${booking['time']}"
                            ),
                          ],
                        ),
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
