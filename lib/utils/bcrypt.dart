import 'package:bcrypt/bcrypt.dart';

class EncryptionService {
  // Salt rounds (higher is more secure but slower)
  static const saltRounds = 12;

  // Hash password with bcrypt
  static String hashPassword(String password) {
    return BCrypt.hashpw(password, BCrypt.gensalt(logRounds: saltRounds));
  }

  // Verify password against hash
  static bool verifyPassword(String password, String hash) {
    return BCrypt.checkpw(password, hash);
  }
}