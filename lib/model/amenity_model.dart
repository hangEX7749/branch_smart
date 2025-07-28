class Amenity {

  String id;
  String amenityName;
  String? description;
  int maxCapacity;
  int status;

  // Predefined status codes
  static const int active = 10;
  static const int inactive = 90;
  static const int unknown = 99;

  Amenity({
    required this.id,
    required this.amenityName,
    this.description,
    required this.maxCapacity,
    required this.status,
  });

  String getStatusName() {
    switch (status) {
      case active:
        return 'Active';
      case inactive:
        return 'Inactive';
      default:
        return 'Unknown';
    }
  }

  static const String allStatusLabel = 'All';
  static final Map<String, int?> statusFilterOptions = {
    allStatusLabel: null,
    'Active': active,
    'Inactive': inactive,
  };

  //status code to name
  static String statusCodeToName(int status) {
    switch (status) {
      case active:
        return 'Active';
      case inactive:
        return 'Inactive';
      default:
        return 'Unknown';
    }
  }

}