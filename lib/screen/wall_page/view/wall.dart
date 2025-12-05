import 'dart:io';
import 'package:branch_comm/admin_screen/member_group/mixins/name_fetching_mixin.dart';
import 'package:branch_comm/model/wall_model.dart';
import 'package:branch_comm/services/database/group_service.dart';
import 'package:branch_comm/services/database/user_service.dart';
import 'package:branch_comm/services/database/wall_servide.dart';
import 'package:branch_comm/services/google_drive.dart';
import 'package:branch_comm/services/shared_pref.dart';
import 'package:branch_comm/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';

class WallPage extends StatefulWidget {
  final String? userId;
  final String? groupId;
  const WallPage({super.key, this.userId, this.groupId});

  @override
  State<WallPage> createState() => _WallPageState();
}

class _WallPageState extends State<WallPage> with NameFetchingMixin{
  String? userId, groupId;
  Uint8List? _avatarImageBytes;
  
  final formKey = GlobalKey<FormState>();
  final WallService _wallService = WallService();
  final UserService _userService = UserService();
  final GroupService _groupService = GroupService();

  final TextEditingController _commentController = TextEditingController();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool isUploading = false;

  @override
  UserService get userService => _userService;
  @override
  GroupService get groupService => _groupService;

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

    final proceed = await _wallService.addWallPost({
      'id': await _wallService.getNewId(),
      'user_id': widget.userId ?? 'anonymous',
      'group_id': widget.groupId ?? 'default_group',
      'comment': _commentController.text.trim(),
      'image_url': imageUrl,
      'status': WallModel.active,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;
    if (!proceed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to upload post. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Post uploaded successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    setState(() {
      _commentController.clear();
      _imageFile = null;
      isUploading = false;
    });
  }

  Future<void> _loadUserAvatarImage() async {
    if (userId == null) {
      // If userId is null, fall back directly to the default asset
      final ByteData defaultByteData = await rootBundle.load('images/boy.jpg');
      setState(() {
        _avatarImageBytes = defaultByteData.buffer.asUint8List();
      });
      //print('Profile image loaded from: Default Asset (no userId)');
      return;
    }
    
    final localPath = '${(await getApplicationDocumentsDirectory()).path}/profile_$userId.jpg';
    final localFile = File(localPath);
    
    Uint8List? imageData;
    final driveFileId = await SharedpreferenceHelper().getProfileImageDriveId(userId!);
    
    //print('Drive File ID: $driveFileId');

    if (driveFileId != null) {
      try {
        final driveService = GoogleDriveService();
        await driveService.initialize();
        imageData = await driveService.downloadImage(driveFileId);
        //print('Profile image loaded from: Google Drive');
      } catch (e) {
        //print('Failed to load from Google Drive: $e');
      }
    }

    // --- MODIFICATION STARTS HERE ---
    Uint8List? finalImageBytes = imageData; // Try Drive first

    if (finalImageBytes == null && localFile.existsSync()) {
      // Try Local File second
      finalImageBytes = localFile.readAsBytesSync();
      //print('Profile image loaded from: Local File');
    }

    if (finalImageBytes == null) {
      // If both failed, load the Default Asset image bytes
      final ByteData defaultByteData = await rootBundle.load('images/boy.jpg');
      finalImageBytes = defaultByteData.buffer.asUint8List();
      //print('Profile image loaded from: Default Asset');
    }

    setState(() {
      _avatarImageBytes = finalImageBytes;
    });
  }

  Future<Widget> _getUserProfileImage() async {
    final localPath = '${(await getApplicationDocumentsDirectory()).path}/profile_$userId.jpg';
    final localFile = File(localPath);
    
    // Check for Google Drive synced image
    final driveFileId = await SharedpreferenceHelper().getProfileImageDriveId(userId!);
    ImageProvider? profileImage;

    //print('Drive File ID: $driveFileId');

    if (driveFileId != null) {
      try {
        // Try to load from Google Drive
        final driveService = GoogleDriveService();
        await driveService.initialize();
        final imageData = await driveService.downloadImage(driveFileId);
        
        if (imageData != null) {
          profileImage = MemoryImage(imageData);
        }
      } catch (e) {
        //print('Failed to load from Google Drive: $e');
      }
    }

    // Fallback to local file or default
    profileImage ??= localFile.existsSync()
        ? FileImage(localFile)
        : const AssetImage('images/boy.jpg') as ImageProvider;


    //print('Profile image loaded from: ${isFromDrive ? "Google Drive" : localFile.existsSync() ? "Local File" : "Default Asset"}');

    return CircleAvatar(
      backgroundImage: profileImage,
      radius: 20,
    );
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Just now';
    final now = DateTime.now();
    final postTime = timestamp.toDate();
    final difference = now.difference(postTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  void initState() {
    super.initState();
    userId = widget.userId;
    groupId = widget.groupId;

    if (userId != null) {
      _loadUserAvatarImage();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Community Wall'),
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Create Post Section
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  spreadRadius: 1,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      radius: 18,
                      backgroundImage: _avatarImageBytes != null
                          ? MemoryImage(_avatarImageBytes!)
                          : null,
                      child: _avatarImageBytes == null
                          ? const Icon(Icons.person, color: Colors.white, size: 20)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "What's on your mind?",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _commentController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Share something with the community...',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Theme.of(context).primaryColor),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                if (_imageFile != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _imageFile!,
                            width: double.infinity,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () => setState(() => _imageFile = null),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: _pickImage,
                      icon: Icon(Icons.image_outlined, color: Colors.grey[600]),
                      label: Text(
                        'Add Photo',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: isUploading ? null : _uploadPost,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: isUploading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Post'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Posts List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _wallService.getWallPosts(widget.groupId ?? 'default_group'),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading posts',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final posts = snapshot.data!.docs;

                if (posts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.message_outlined, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No posts yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Be the first to share something!',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index].data() as Map<String, dynamic>;
                    final timestamp = post['timestamp'] as Timestamp?;
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.1),
                            spreadRadius: 1,
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Post Header
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                FutureBuilder<Widget>(
                                  future: _getUserProfileImage(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return CircleAvatar(
                                        backgroundColor: Theme.of(context).primaryColor,
                                        radius: 20,
                                        child: const CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      );
                                    }
                                    if (snapshot.hasError || !snapshot.hasData) {
                                      return CircleAvatar(
                                        backgroundColor: Theme.of(context).primaryColor,
                                        radius: 20,
                                        child: const Icon(
                                          Icons.person, 
                                          color: Colors.white, 
                                          size: 20
                                        ),
                                      );
                                    }
                                    return snapshot.data!;
                                  },
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      FutureBuilder<String>(
                                        future: getUserName(post['user_id']),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState == ConnectionState.waiting) {
                                            return const Text(
                                              'Loading...',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey,
                                              ),
                                            );
                                          }
                                          if (snapshot.hasError || !snapshot.hasData) {
                                            return const Text(
                                              'Unknown User',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey,
                                              ),
                                            );
                                          }
                                          return Text(
                                            snapshot.data!,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          );
                                        },
                                      ),
                                      Text(
                                        _formatTimestamp(timestamp),
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Post Content
                          if (post['comment'] != null && post['comment'].isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                post['comment'],
                                style: const TextStyle(
                                  fontSize: 15,
                                  height: 1.4,
                                ),
                              ),
                            ),

                          // Post Image
                          if (post['imageUrl'] != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                ),
                                child: Image.network(
                                  post['imageUrl'],
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      height: 200,
                                      color: Colors.grey[200],
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 200,
                                      color: Colors.grey[200],
                                      child: Icon(
                                        Icons.broken_image,
                                        color: Colors.grey[400],
                                        size: 48,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),

                          if (post['comment'] != null && 
                              post['comment'].isNotEmpty && 
                              post['imageUrl'] == null)
                            const SizedBox(height: 16),
                        ],
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