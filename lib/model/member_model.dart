class Member {
  String id;
  String name;
  String email;
  String? phoneNumber;
  String? status;

  // Predefined status codes
  static const String active = '10';
  static const String pending = '30';
  static const String inactive = '90';

  Member({
    required this.id,
    required this.name,
    required this.email,
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