class AmenityGroup {

  String id;
  String groupId;
  String amenityId;

  AmenityGroup({
    required this.id,
    required this.groupId,
    required this.amenityId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'group_id': groupId,
      'amenity_id': amenityId,
    };
  }

  factory AmenityGroup.fromMap(Map<String, dynamic> map) {
    return AmenityGroup(
      id: map['id'] ?? '',
      groupId: map['group_id'] ?? '',
      amenityId: map['amenity_id'] ?? '',
    );
  }

  @override
  String toString() {
    return 'AmenityGroup(id: $id, groupId: $groupId, amenityId: $amenityId)';
  }

}