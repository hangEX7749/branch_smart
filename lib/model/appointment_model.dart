class AppointmentModel {

  String id;
  String? guestName;
  String? contactNum;
  String? userId;
  String? venue;
  int? numGuests = 1; // Default to 1 person
  int? appointmentType; // 'invite'
  int? status; // 10 = Completed, 30 = Pending, 50 = Failed
  DateTime? inviteDateTime;
  DateTime? expiredDateTime;
  DateTime? createdAt;
  DateTime? updatedAt;

  //Predefined appointment types
  static const int invite = 10; // Invite

  // Predefined status codes
  static const int completed = 10;
  static const int pending = 30;
  static const int failed = 50;

  AppointmentModel({
    required this.id,
    this.guestName,
    this.contactNum,
    required this.userId,
    required this.venue,
    this.numGuests,
    required this.appointmentType,
    this.status,
    required this.inviteDateTime,
    this.expiredDateTime,
    this.createdAt,
    this.updatedAt,
  });

  String getStatusName() {
    switch (status) {
      case completed:
        return 'Completed';
      case pending:
        return 'Pending';
      case failed:
        return 'Failed';
      default:
        return 'Error';
    }
  }

  String getAppointmentTypeName() {
    switch (appointmentType) {
      case invite:
        return 'Invite';
      default:
        return 'Unknown';
    }
  }

}