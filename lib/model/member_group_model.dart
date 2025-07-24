class MemberGroup {

  final String id;
  final String memberId;
  final String groupId;
  final int stauts; // Assuming this is an integer status code
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Predefined status codes
  static const int active = 10;
  static const int pending = 20;
  static const int rejected = 30;
  static const int inactive = 90;

  MemberGroup({
    required this.id,
    required this.memberId,
    required this.groupId,
    required this.stauts,
    this.createdAt,
    this.updatedAt
  });

  factory MemberGroup.fromJson(Map<String, dynamic> json) {
    return MemberGroup(
      id: json['id'] as String,
      memberId: json['member_id'] as String,
      groupId: json['group_id'] as String,
      stauts: json['status'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json.containsKey('updated_at') ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'member_id': memberId,
      'group_id': groupId,
      'status': stauts,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

}