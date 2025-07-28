import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class WallService {
  final _wallPosts = FirebaseFirestore.instance.collection("wall_posts");
  //final _users = FirebaseFirestore.instance.collection("users");

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
  Future<void> addWallPost({
    required String userId,
    required String comment,
    String? imageUrl,
  }) async {
    try {
      await _wallPosts.add({
        "userId": userId,
        "comment": comment,
        "imageUrl": imageUrl,
        "timestamp": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      //print("Error adding wall post: $e");
    }
  }

  /// Gets wall posts in descending order of timestamp
  Stream<QuerySnapshot> getWallPosts() {
    return _wallPosts.orderBy("timestamp", descending: true).snapshots();
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
