import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class WallPage extends StatefulWidget {
  const WallPage({super.key});

  @override
  State<WallPage> createState() => _WallPageState();
}

class _WallPageState extends State<WallPage> {
  final TextEditingController _commentController = TextEditingController();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool isUploading = false;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<void> _uploadPost() async {
    if (_commentController.text.isEmpty && _imageFile == null) return;

    setState(() => isUploading = true);

    String? imageUrl;
    if (_imageFile != null) {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = FirebaseStorage.instance.ref().child('wall_images/$fileName.jpg');
      await ref.putFile(_imageFile!);
      imageUrl = await ref.getDownloadURL();
    }

    await FirebaseFirestore.instance.collection('wall_posts').add({
      'userId': FirebaseFirestore.instance.collection('users').doc().id, // Replace with actual user ID
      'comment': _commentController.text,
      'imageUrl': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
    });

    setState(() {
      _commentController.clear();
      _imageFile = null;
      isUploading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Community Wall'), backgroundColor: Colors.deepPurple),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: _commentController,
                  decoration: InputDecoration(labelText: 'Write a comment...'),
                ),
                SizedBox(height: 8),
                _imageFile != null
                    ? Stack(
                        children: [
                          Image.file(_imageFile!, height: 150),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: IconButton(
                              icon: Icon(Icons.close, color: Colors.red),
                              onPressed: () => setState(() => _imageFile = null),
                            ),
                          )
                        ],
                      )
                    : TextButton.icon(
                        onPressed: _pickImage,
                        icon: Icon(Icons.image),
                        label: Text("Add Image"),
                      ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: isUploading ? null : _uploadPost,
                  child: isUploading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Post'),
                ),
              ],
            ),
          ),
          Divider(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('wall_posts')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text('Error loading posts'));
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                final posts = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index].data() as Map<String, dynamic>;
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        title: Text(post['comment'] ?? ''),
                        subtitle: post['imageUrl'] != null
                            ? Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Image.network(post['imageUrl']),
                              )
                            : null,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
