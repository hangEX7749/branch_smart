import 'dart:io';
import 'package:branch_comm/model/wall_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class WallService {
  final _wallPosts = FirebaseFirestore.instance.collection("wall_posts");
  //final _users = FirebaseFirestore.instance.collection("users");

  /// Generates a new unique ID for a wall post
  Future<String> getNewId() async {
    final docRef = _wallPosts.doc();
    return docRef.id; // Returns a new document ID
  }
  
  /// Uploads image to Firebase Storage and returns the download URL
  Future<String?> uploadImage(File imageFile) async {
    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = FirebaseStorage.instance.ref().child('wall_images/$fileName.jpg');
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      //print("Image upload failed: $e");
      return null;
    }
  }

  /// Adds a new wall post
  Future<bool> addWallPost(Map<String, dynamic> postData) async {
    try {
      final docRef = await _wallPosts.add(postData);
      await docRef.update({'id': docRef.id}); // Update with the new ID
      return true;
    } catch (e) {
      //print("Error adding wall post: $e");
      return false;
    }
  }

  /// Gets wall posts in descending order of timestamp
  Stream<QuerySnapshot> getWallPosts(String groupId) {

    return _wallPosts
      .where("status", isEqualTo: WallModel.active)
      .where("group_id", isEqualTo: groupId)
      .orderBy("created_at", descending: true)
      .snapshots();
  }

  /// Deletes a wall post by ID
  Future<void> deleteWallPost(String postId) async {
    try {
      await _wallPosts.doc(postId).delete();
    } catch (e) {
      //print("Error deleting wall post: $e");
    }
  }
}
