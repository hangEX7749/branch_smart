import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum UserRole {
  user,
  admin,
}

class SiginAuth {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static final _users = FirebaseFirestore.instance.collection("users");
  static final _admins = FirebaseFirestore.instance.collection("admins");

  // Check if user exists in admins collection
  static Future<bool> isUserInAdminCollection() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      DocumentSnapshot adminDoc = await _admins.doc(currentUser.uid).get();

      return adminDoc.exists;
    } catch (e) {
      //print('Error checking admin collection: $e');
      return false;
    }
  }

  // Check if user exists in users collection
  static Future<bool> isUserInUserCollection() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      DocumentSnapshot userDoc = await _users.doc(currentUser.uid).get();

      return userDoc.exists;
    } catch (e) {
      //print('Error checking user collection: $e');
      return false;
    }
  }

  // Get user role based on which collection they exist in
  static Future<UserRole?> getUserRole() async {
    try {
      // First check if user is admin
      bool isInAdminCollection = await isUserInAdminCollection();
      if (isInAdminCollection) {
        return UserRole.admin;
      }

      // Then check if user exists in users collection
      bool isInUserCollection = await isUserInUserCollection();
      if (isInUserCollection) {
        return UserRole.user;
      }

      // User doesn't exist in either collection
      return null;
    } catch (e) {
      //print('Error getting user role: $e');
      return null;
    }
  }

  // Get user data from appropriate collection
  static Future<Map<String, dynamic>?> getUserData() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) return null;

      UserRole? role = await getUserRole();
      
      if (role == UserRole.admin) {
        DocumentSnapshot adminDoc = await _admins.doc(currentUser.uid).get();
        
        if (adminDoc.exists) {
          return adminDoc.data() as Map<String, dynamic>?;
        }
      } else if (role == UserRole.user) {
        DocumentSnapshot userDoc = await _users.doc(currentUser.uid).get();
        
        if (userDoc.exists) {
          return userDoc.data() as Map<String, dynamic>?;
        }
      }

      return null;
    } catch (e) {
      //print('Error getting user data: $e');
      return null;
    }
  }

  // Create user document in appropriate collection
  static Future<void> createUserDocument(User user, UserRole role) async {
    try {
      String collection = role == UserRole.admin ? 'admins' : 'users';
      
      await _firestore.collection(collection).doc(user.uid).set({
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      //print('Error creating user document: $e');
    }
  }

  // Update user's last login time in appropriate collection
  static Future<void> updateLastLogin() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) return;

      UserRole? role = await getUserRole();
      if (role != null) {
        String collection = role == UserRole.admin ? 'admins' : 'users';
        
        await _firestore.collection(collection).doc(currentUser.uid).update({
          'lastLoginAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      //print('Error updating last login: $e');
    }
  }

  // Check if current user is admin
  static Future<bool> isAdmin() async {
    UserRole? role = await getUserRole();
    return role == UserRole.admin;
  }

  // Check if current user exists in system
  static Future<bool> userExistsInSystem() async {
    UserRole? role = await getUserRole();
    return role != null;
  }

  // Move user from users to admins collection (promote to admin)
  static Future<bool> promoteUserToAdmin(String userId) async {
    try {
      // Get user data from users collection
      DocumentSnapshot userDoc = await _users.doc(userId).get();

      if (!userDoc.exists) {
        //print('User not found in users collection');
        return false;
      }

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      
      // Add to admins collection
      await _admins.doc(userId).set({
        ...userData,
        'promotedAt': FieldValue.serverTimestamp(),
      });

      // Remove from users collection
      await _users.doc(userId).delete();

      return true;
    } catch (e) {
      //print('Error promoting user to admin: $e');
      return false;
    }
  }

  // Move admin from admins to users collection (demote from admin)
  static Future<bool> demoteAdminToUser(String userId) async {
    try {
      // Get admin data from admins collection
      DocumentSnapshot adminDoc = await _admins.doc(userId).get();

      if (!adminDoc.exists) {
        //print('Admin not found in admins collection');
        return false;
      }

      Map<String, dynamic> adminData = adminDoc.data() as Map<String, dynamic>;
      
      // Remove admin-specific fields
      adminData.remove('promotedAt');
      
      // Add to users collection
      await _users.doc(userId).set({
        ...adminData,
        'demotedAt': FieldValue.serverTimestamp(),
      });

      // Remove from admins collection
      await _admins.doc(userId).delete();

      return true;
    } catch (e) {
      //print('Error demoting admin to user: $e');
      return false;
    }
  }
}
