class Booking {
  String id;
  String groupId;
  String amenityId;
  String? time;
  String? date;
  String userId;
  int? numGuests = 1;
  int? status;
  // String? createdAt;
  // String? updatedAt;

  // Predefined status codes
  static const int completed= 10;
  static const int pending = 30;
  static const int rejected= 90;
  static const int error = 99;

  Booking({
    required this.id,
    required this.groupId,
    required this.amenityId,
    required this.time,
    required this.date,
    required this.userId,
    required this.numGuests,
    required this.status,
  });

  String getStatusName() {
    switch (status) {
      case completed:
        return 'Completed';
      case pending:
        return 'Pending';
      case rejected:
        return 'Failed';
      default:
        return 'Error';
    }
  }

  static String codeToName (int? code) {
    switch (code) {
      case completed:
        return 'Completed';
      case pending:
        return 'Pending';
      case rejected:
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
    'Failed': rejected,
  };

  static final List<Map<String, dynamic>> statusUpdateOptions = [
    {'value': completed, 'label': 'Mark as Completed'},
    {'value': pending, 'label': 'Mark as Pending'},
    {'value': rejected, 'label': 'Mark as Failed'},
    {'value': error, 'label': 'Mark as Error'},
  ];

  static List<int> get validStatusCodes => [completed, pending, rejected, error];
}


