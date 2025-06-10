import 'package:shared_preferences/shared_preferences.dart';

class SharedpreferenceHelper {
  static const String userIdKey = 'USERKEY';
  static const String userNameKey = 'USERNAMEKEY';
  static const String userEmailKey = 'USEREMAILKEY';
  static const String userImageKey = 'USERIMAGEKEY';
  static const String userAddressKey = 'USERADDRESSKEY';

  Future<bool> saveUserId(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(userIdKey, userId);
  }

  Future<bool> saveUserName(String userName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(userNameKey, userName);
  }

  Future<bool> saveUserEmail(String userEmail) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(userEmailKey, userEmail);
  }

  Future<bool> saveUserImage(String userImage) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(userImageKey, userImage);
  }

  Future<bool> saveUserAddress(String userAddress) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(userAddressKey, userAddress);
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



