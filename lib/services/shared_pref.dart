import 'package:branch_comm/model/member_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedpreferenceHelper {
  static const String userIdKey = 'USERKEY';
  static const String userNameKey = 'USERNAMEKEY';
  static const String userEmailKey = 'USEREMAILKEY';
  static const String userImageKey = 'USERIMAGEKEY';
  static const String userPhoneNumberKey = 'USERPHONEKEY';
  static const int userStatusKey = 30;
  static const String userAddressKey = 'USERADDRESSKEY';
  static const String profileImageDriveIdPrefix = "PROFILE_IMAGE_DRIVE_ID_";
  static const String profileImageSyncStatusPrefix = "PROFILE_IMAGE_SYNC_";

  Future<bool> clearAllPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.clear();
  }

  Future<bool> saveUserData({
    required String userId,
    required String userName,
    required String userEmail,
    String? userImage, // Optional
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save all fields in one transaction
    return await Future.wait([
      prefs.setString(userIdKey, userId),
      prefs.setString(userNameKey, userName),
      prefs.setString(userEmailKey, userEmail),
      if (userImage != null) prefs.setString(userImageKey, userImage),
    ]).then((results) => results.every((success) => success));
  }

  Future<bool> saveUserAddress(String userAddress) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(userAddressKey, userAddress);
  }

  Future<Member> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    return Member(
      id: prefs.getString(userIdKey) ?? '',
      name: prefs.getString(userNameKey) ?? '',
      email: prefs.getString(userEmailKey) ?? '',
      phoneNumber: prefs.getString(userPhoneNumberKey) ?? '',
      //image: prefs.getString(userImageKey),
    );
  }
  Future<String?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userIdKey);
  }

  Future<String?> getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userNameKey);
  }

  Future<String?> getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userEmailKey);
  }

  Future<String?> getUserImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userImageKey);
  }

  Future<String?> getUserAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userAddressKey);
  }

  //////////////////////////////////////////////////////////////////////////////////////////////
  //Google Drive Integration for Profile Image
   // Save Google Drive file ID for profile image
  Future<bool> saveProfileImageDriveId(String userId, String driveFileId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString("$profileImageDriveIdPrefix$userId", driveFileId);
  }

  Future<String?> getProfileImageDriveId(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("$profileImageDriveIdPrefix$userId");
  }

  Future<bool> removeProfileImageDriveId(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.remove("$profileImageDriveIdPrefix$userId");
  }

  // Save profile image sync status
  Future<bool> saveProfileImageSyncStatus(String userId, bool isSynced) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool("$profileImageSyncStatusPrefix$userId", isSynced);
  }

  Future<bool> getProfileImageSyncStatus(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool("$profileImageSyncStatusPrefix$userId") ?? false;
  }

  // Clear all profile image related data (call this in your existing clearAllPref method)
  Future<void> clearProfileImageData(String userId) async {
    await removeProfileImageDriveId(userId);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("$profileImageSyncStatusPrefix$userId");
  }
}



