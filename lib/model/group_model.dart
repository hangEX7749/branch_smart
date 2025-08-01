class Group{
  String id;
  String iid; // admin id who initiated
  String groupName;
  String? description;
  int? status;
  DateTime? createdAt;
  DateTime? updatedAt;

  // Predefined status codes
  static const int active = 10;
  static const int inactive = 90;
  static const int unknown = 99;

  Group({
    required this.id,
    required this.iid, // admin id who initiated
    required this.groupName,
    this.description,
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

  static int getStatusCode(code) {
    switch (code) {
      case active:
        return active;
      case inactive:
        return inactive;
      default:
        return 0; // Default case if status is unknown
    }
  }

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

  static const String allStatusLabel = 'All';
  static final Map<String, int?> statusFilterOptions = {
    'All': -1,
    'Active': active,
    'Inactive': inactive,
  };

  // Status popup menu options
  static const List<String> statusPopupOptions = [
    'Active',
    'Inactive',
  ];

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'] as String,
      iid: json['iid'] as String, // admin id who initiated
      status: json['status'] as int,
      groupName: json['group_name'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'iid': iid, // admin id who initiated
      'status': status,
      'group_name': groupName,
      'description': description,
    };
  }
} 