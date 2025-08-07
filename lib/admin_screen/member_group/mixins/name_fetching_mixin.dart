import 'package:branch_comm/services/database/user_service.dart';
import 'package:branch_comm/services/database/group_service.dart';

mixin NameFetchingMixin {
  // Cache to store fetched names to avoid repeated API calls
  final Map<String, String> _groupNameCache = {};
  final Map<String, String> _userNameCache = {};

  // These need to be provided by the class using this mixin
  UserService get userService;
  GroupService get groupService;

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

  void clearNameCache() {
    _groupNameCache.clear();
    _userNameCache.clear();
  }
}