import 'package:branch_comm/model/admin_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminSharedPreferenceHelper {
  static const String adminIdKey = 'ADMINIDKEY';
  static const String adminNameKey = 'ADMINNAMEKEY';
  static const String adminEmailKey = 'ADMINEMAILKEY';
  static const String adminStatusKey = 'ADMINSTATUSKEY';

  Future<bool> clearAllPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.clear();
  }

  Future<bool> saveAdminData({
    required String adminId,
    required String adminName,
    required String adminEmail,
    required int adminStatus,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    return await Future.wait([
      prefs.setString(adminIdKey, adminId),
      prefs.setString(adminNameKey, adminName),
      prefs.setString(adminEmailKey, adminEmail),
      //prefs.setString(adminStatusKey, adminStatus as String),
      prefs.setInt(adminStatusKey, adminStatus),
    
    ]).then((results) => results.every((success) => success));
  }

  Future<Admin> getAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    return Admin(
      uid: prefs.getString(adminIdKey) ?? '',
      name: prefs.getString(adminNameKey) ?? '',
      email: prefs.getString(adminEmailKey) ?? '',
      status: prefs.getInt(adminStatusKey) ?? 0
    );
  }

  Future<String?> getAdminId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(adminIdKey);
  }

  Future<String?> getAdminName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(adminNameKey);
  }

  Future<String?> getAdminEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(adminEmailKey);
  }

  Future<String?> getAdminStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(adminStatusKey)?.toString();
  }
}