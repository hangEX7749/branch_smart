class Appointment {

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

  Appointment({
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

  static const String allStatusLabel = 'All';
  static final Map<String, int?> statusFilterOptions = {
    allStatusLabel: null,
    'Completed': completed,
    'Pending': pending,
    'Failed': failed,
  };

  // Status popup menu options
  static final List<Map<String, dynamic>> statusUpdateOptions = [
    {'value': completed, 'label': 'Mark as Completed'},
    {'value': pending, 'label': 'Mark as Pending'},
    {'value': failed, 'label': 'Mark as Failed'},
  ];

  /// Gets all valid status codes
  static List<int> get validStatusCodes => [completed, pending, failed];

  /// Checks if a status code is valid
  static bool isValidStatus(int? code) {
    return code != null && validStatusCodes.contains(code);
  }

  static String codeToName(int code) {
    switch (code) {
      case completed:
        return 'Completed';
      case pending:
        return 'Pending';
      case failed:
        return 'Failed';
      default:
        return 'Unknown';
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