class Member {
  String id;
  String name;
  String email;
  String? groupId; 
  String? phoneNumber;
  int? status;

  // Predefined status codes
  static const int active = 10;
  static const int pending = 30;
  static const int inactive = 90;

  Member({
    required this.id,
    required this.name,
    required this.email,
    this.groupId,
    this.phoneNumber,
    this.status,
  });


  String getStatusName() {
    switch (status) {
      case active:
        return 'Active';
      case pending:
        return 'Pending';
      case inactive:
        return 'Inactive';
      default:
        return 'Error';
    }
  }

  // Static label for all status
  static const String allStatusLabel = 'All';

  // Static map for status filter options
  static const Map<String, int?> statusFilterOptions = {
    allStatusLabel: null,
    'Active': active,
    'Pending': pending,
    'Inactive': inactive,
  };

  // Static method status options
  static List<Map<String, dynamic>> get statusOptions => [
    {'label': 'Active', 'value': active},
    {'label': 'Pending', 'value': pending},
    {'label': 'Inactive', 'value': inactive},
  ];

  // @override
  // String toString() {
  //   return 'Member{id: $id, name: $name, email: $email, phoneNumber: $phoneNumber}';
  // }

  // // Factory constructor to create a Member from a Map
  // factory Member.fromMap(Map<String, dynamic> data) {
  //   return Member(
  //     id: data['id'] ?? '',
  //     name: data['name'] ?? '',
  //     email: data['email'] ?? '',
  //     phoneNumber: data['phoneNumber'] ?? '',
  //   );
  // }

  // // Method to convert a Member to a Map
  // Map<String, dynamic> toMap() {
  //   return {
  //     'id': id,
  //     'name': name,
  //     'email': email,
  //     'phoneNumber': phoneNumber,
  //   };
  // }
}