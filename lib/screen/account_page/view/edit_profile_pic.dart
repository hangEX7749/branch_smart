import 'dart:io';
import 'package:branch_comm/services/database/user_service.dart';
import 'package:branch_comm/services/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:branch_comm/services/google_drive.dart';

class ProfilePicturePage extends StatefulWidget {
  final String userId;

  const ProfilePicturePage({super.key, required this.userId});

  @override
  State<ProfilePicturePage> createState() => _ProfilePicturePageState();
}

class _ProfilePicturePageState extends State<ProfilePicturePage> {
  final GoogleDriveService _driveService = GoogleDriveService();
  final UserService _userService = UserService();
  final ImagePicker _picker = ImagePicker();
  
  File? _selectedImage;
  bool _isUploading = false;
  bool _isLoading = true;
  String? _currentDriveFileId;
  ImageProvider? _profileImage;

  @override
  void initState() {
    super.initState();
    _loadCurrentProfilePicture();
  }

  Future<void> _loadCurrentProfilePicture() async {
    setState(() => _isLoading = true);

    try {
      // Check if we have a stored Google Drive file ID
      _currentDriveFileId = await SharedpreferenceHelper()
          .getProfileImageDriveId(widget.userId);

      if (_currentDriveFileId != null) {
        // Try to download from Google Drive
        await _driveService.initialize();
        final imageData = await _driveService.downloadImage(_currentDriveFileId!);
        
        if (imageData != null) {
          setState(() {
            _profileImage = MemoryImage(imageData);
          });
        } else {
          // Fallback to local image
          _loadLocalImage();
        }
      } else {
        // Load local image
        _loadLocalImage();
      }
    } catch (e) {
      //print('Error loading profile picture: $e');
      _loadLocalImage();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _loadLocalImage() {
    final localPath = '${Directory.systemTemp.path}/profile_${widget.userId}.jpg';
    final localFile = File(localPath);
    
    if (localFile.existsSync()) {
      setState(() {
        _profileImage = FileImage(localFile);
      });
    } else {
      setState(() {
        _profileImage = const AssetImage('images/boy.jpg');
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _profileImage = FileImage(_selectedImage!);
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image: $e');
    }
  }

  Future<void> _uploadToGoogleDrive() async {
    if (_selectedImage == null) return;

    setState(() => _isUploading = true);

    try {
      final fileName = 'profile_${widget.userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Initialize Google Drive service
      final initialized = await _driveService.initialize();

      //print('Google Drive initialized: $initialized');
      if (!initialized) {
        throw Exception('Failed to initialize Google Drive');
      }

      String? fileId;

      // Upload to organized folder structure: BranchComm/ProfileImages/User_[userId]/
      fileId = await _driveService.uploadImageToUserFolder(
        imageFile: _selectedImage!,
        fileName: fileName,
        userId: widget.userId,
        existingFileId: _currentDriveFileId, // This will update existing file if not null
      );

      if (fileId != null) {
        // Save file ID to preferences
        await SharedpreferenceHelper().saveProfileImageDriveId(widget.userId, fileId);
        
        // Also save locally as backup
        await _saveImageLocally();

        //save in firebase
        await _userService.updateProfilePic(fileName, widget.userId);
        
        _currentDriveFileId = fileId;
        
        _showSuccessSnackBar('Profile picture uploaded successfully!');

        if (!mounted) return;
        Navigator.pop(context, true); // Return true to indicate success
      } else {
        throw Exception('Upload failed');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to upload: $e');
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _saveImageLocally() async {
    if (_selectedImage == null) return;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final localPath = '${directory.path}/profile_${widget.userId}.jpg';
      await _selectedImage!.copy(localPath);
    } catch (e) {
      //print('Error saving image locally: $e');
    }
  }

  Future<void> _deleteProfilePicture() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Profile Picture'),
        content: const Text('Are you sure you want to delete your profile picture?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isUploading = true);

      try {
        if (_currentDriveFileId != null) {
          await _driveService.deleteImage(_currentDriveFileId!);
          await SharedpreferenceHelper()
              .removeProfileImageDriveId(widget.userId);
        }

        // Delete local file
        final directory = await getApplicationDocumentsDirectory();
        final localFile = File('${directory.path}/profile_${widget.userId}.jpg');
        if (localFile.existsSync()) {
          await localFile.delete();
        }

        setState(() {
          _currentDriveFileId = null;
          _selectedImage = null;
          _profileImage = const AssetImage('images/boy.jpg');
        });

        _showSuccessSnackBar('Profile picture deleted successfully!');
      } catch (e) {
        _showErrorSnackBar('Failed to delete: $e');
      } finally {
        setState(() => _isUploading = false);
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Image Source',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Picture'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          if (_currentDriveFileId != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _isUploading ? null : _deleteProfilePicture,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Profile Picture Display
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey[300]!, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 96,
                            backgroundImage: _profileImage,
                            backgroundColor: Colors.grey[200],
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: GestureDetector(
                            onTap: _isUploading ? null : _showImageSourceDialog,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Upload Status
                  if (_isUploading)
                    const Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Uploading to Google Drive...'),
                        SizedBox(height: 20),
                      ],
                    ),

                  // Action Buttons
                  if (_selectedImage != null && !_isUploading) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _uploadToGoogleDrive,
                        icon: const Icon(Icons.cloud_upload),
                        label: Text(_currentDriveFileId != null 
                            ? 'Update Profile Picture' 
                            : 'Upload to Google Drive'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isUploading ? null : _showImageSourceDialog,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Select New Picture'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Info Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, 
                                   color: Theme.of(context).primaryColor),
                              const SizedBox(width: 8),
                              const Text(
                                'Storage Information',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Your profile picture is stored securely in Google Drive and synchronized across all your devices. '
                            'The image is also cached locally for faster loading.',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (_currentDriveFileId != null)
                            Text(
                              'Status: Synced with Google Drive',
                              style: TextStyle(
                                color: Colors.green[600],
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          else
                            Text(
                              'Status: Local only',
                              style: TextStyle(
                                color: Colors.orange[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}