class BookingModel {
  String id;
  String? amenity;
  String? time;
  String? date;
  String? userId;
  String? status;
  // String? createdAt;
  // String? updatedAt;

  // Predefined status codes
  static const String active = '10';
  static const String pending = '30';
  static const String inactive = '90';

  BookingModel({
    required this.id,
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
}


