class Booking {
  String id;
  String groupId; 
  String? amenity;
  String? time;
  String? date;
  String? userId;
  int? status;
  // String? createdAt;
  // String? updatedAt;

  // Predefined status codes
  static const int active = 10;
  static const int pending = 30;
  static const int inactive = 90;
  static const int error = 99;

  Booking({
    required this.id,
    required this.groupId,
    required this.amenity,
    required this.time,
    required this.date,
    required this.userId,
    required this.status,
  });

  String getStatusName() {
    switch (status) {
      case active:
        return 'Completed';
      case pending:
        return 'Pending';
      case inactive:
        return 'Failed';
      default:
        return 'Error';
    }
  }

  static const String allStatusLabel = 'All';
  static final Map<String, int?> statusFilterOptions = {
    allStatusLabel: null,
    'Completed': active,
    'Pending': pending,
    'Failed': inactive,
  };

  static final List<Map<String, dynamic>> statusUpdateOptions = [
    {'value': active, 'label': 'Mark as Completed'},
    {'value': pending, 'label': 'Mark as Pending'},
    {'value': inactive, 'label': 'Mark as Failed'},
    {'value': error, 'label': 'Mark as Error'},
  ];

  static List<int> get validStatusCodes => [active, pending, inactive, error];
}


