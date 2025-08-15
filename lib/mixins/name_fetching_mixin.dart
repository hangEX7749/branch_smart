import 'package:branch_comm/services/database/amenity_service.dart';
import 'package:branch_comm/services/database/user_service.dart';
import 'package:branch_comm/services/database/group_service.dart';

mixin NameFetchingMixin {
  // Cache to store fetched names to avoid repeated API calls
  final Map<String, String> _groupNameCache = {};
  final Map<String, String> _userNameCache = {};
  final Map<String, String> _amenityNameCache = {};

  // These need to be provided by the class using this mixin
  UserService get userService;
  GroupService get groupService;
  AmenityService get amenityService;

  Future<String> getGroupName(String groupId) async {
    if (_groupNameCache.containsKey(groupId)) {
      return _groupNameCache[groupId]!;
    }

    try {
      final groupName = await groupService.getGroupNameById(groupId);
      final name = groupName ?? 'Unknown Group';
      _groupNameCache[groupId] = name;
      return name;
    } catch (e) {
      _groupNameCache[groupId] = 'Error loading group';
      return 'Error loading group';
    }
  }

  Future<String> getUserName(String userId) async {
    if (_userNameCache.containsKey(userId)) {
      return _userNameCache[userId]!;
    }

    try {
      final userName = await userService.getUserNameById(userId);
      final name = userName ?? 'Unknown User';
      _userNameCache[userId] = name;
      return name;
    } catch (e) {
      _userNameCache[userId] = 'Error loading user';
      return 'Error loading user';
    }
  }

  Future<String> getAmenityName(String amenityId) async {
    if (_amenityNameCache.containsKey(amenityId)) {
      return _amenityNameCache[amenityId]!;
    }

    try {
      final amenityName = await amenityService.getAmenityNameById(amenityId);
      final name = amenityName ?? 'Unknown Amenity';
      _amenityNameCache[amenityId] = name;
      return name;
    } catch (e) {
      _amenityNameCache[amenityId] = 'Error loading amenity';
      return 'Error loading amenity';
    }
  }

  void clearNameCache() {
    _groupNameCache.clear();
    _userNameCache.clear();
    _amenityNameCache.clear();
  }
}