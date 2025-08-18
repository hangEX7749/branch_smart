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
}



