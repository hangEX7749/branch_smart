class WallModel {

  final String id;
  final String userId;
  final String groupId;
  final int status; // Assuming this is an integer status code
  final String comment;
  final String? imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Predefined status codes
  static const int active = 10;
  static const int pending = 20;
  static const int rejected = 30;
  static const int inactive = 90;

  WallModel({
    required this.id,
    required this.userId,
    required this.groupId,
    required this.status,
    required this.comment,
    this.imageUrl,
    this.createdAt,
    this.updatedAt
  });
}