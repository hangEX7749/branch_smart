import 'dart:io';
import 'dart:typed_data';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class GoogleDriveService {
  static final GoogleDriveService _instance = GoogleDriveService._internal();
  factory GoogleDriveService() => _instance;
  GoogleDriveService._internal();

  // App-specific folder structure
  // ignore_for_file: constant_identifier_names
  static const String APP_ROOT_FOLDER = 'BranchComm';
  static const String PROFILE_IMAGES_FOLDER = 'ProfileImages';
  static const String USER_FOLDERS_PREFIX = 'User_';

  drive.DriveApi? _driveApi;
  GoogleSignIn? _googleSignIn;

  // Initialize Google Drive service
  Future<bool> initialize() async {
    try {
      _googleSignIn = GoogleSignIn(
        scopes: [
          'https://www.googleapis.com/auth/drive.file',
          'https://www.googleapis.com/auth/drive.appdata',
        ],
      );

      final GoogleSignInAccount? account = await _googleSignIn!.signIn();

      //print('Google Sign-In account: $account');

      if (account == null) return false;

      final GoogleSignInAuthentication authentication = 
          await account.authentication;

      final AuthClient client = authenticatedClient(
        http.Client(),
        AccessCredentials(
          AccessToken(
            'Bearer',
            authentication.accessToken!,
            DateTime.now().add(const Duration(hours: 1)).toUtc(),
          ),
          authentication.idToken,
          [
            'https://www.googleapis.com/auth/drive.file',
            'https://www.googleapis.com/auth/drive.appdata',
          ],
        ),
      );

      _driveApi = drive.DriveApi(client);
      return true;
    } catch (e) {
      //print('Error initializing Google Drive: $e');
      return false;
    }
  }

  // Upload image to Google Drive
  Future<String?> uploadImage({
    required File imageFile,
    required String fileName,
    String? folderId,
  }) async {
    try {
      if (_driveApi == null) {
        final initialized = await initialize();
        if (!initialized) return null;
      }

      // Read image file
      final Uint8List imageBytes = await imageFile.readAsBytes();

      // Create file metadata
      final drive.File fileMetadata = drive.File()
        ..name = fileName
        ..parents = folderId != null ? [folderId] : null;

      // Create media upload
      final drive.Media media = drive.Media(
        Stream.value(imageBytes),
        imageBytes.length,
        contentType: _getContentType(fileName),
      );

      // Upload file
      final drive.File uploadedFile = await _driveApi!.files.create(
        fileMetadata,
        uploadMedia: media,
      );

      return uploadedFile.id;
    } catch (e) {
      //print('Error uploading image: $e');
      return null;
    }
  }

  // Upload image to specific user folder
  Future<String?> uploadImageToUserFolder({
    required File imageFile,
    required String fileName,
    required String userId,
    String? existingFileId,
  }) async {
    try {
      if (_driveApi == null) {
        final initialized = await initialize();
        if (!initialized) return null;
      }

      // Get the user's specific folder
      final String? userFolderId = await getOrCreateAppFolders(userId);
      if (userFolderId == null) {
        throw Exception('Failed to create user folder');
      }

      // Read image file
      final Uint8List imageBytes = await imageFile.readAsBytes();

      if (existingFileId != null) {
        // Update existing file
        final drive.Media media = drive.Media(
          Stream.value(imageBytes),
          imageBytes.length,
          contentType: _getContentType(fileName),
        );

        final drive.File updatedFile = await _driveApi!.files.update(
          drive.File(),
          existingFileId,
          uploadMedia: media,
        );

        //print('Updated file: ${updatedFile.name} in user folder');
        return updatedFile.id;
      } else {
        // Create new file in user folder
        final drive.File fileMetadata = drive.File()
          ..name = fileName
          ..parents = [userFolderId]; // Specify the user folder as parent

        final drive.Media media = drive.Media(
          Stream.value(imageBytes),
          imageBytes.length,
          contentType: _getContentType(fileName),
        );

        final drive.File uploadedFile = await _driveApi!.files.create(
          fileMetadata,
          uploadMedia: media,
        );

        //print('Uploaded file: ${uploadedFile.name} to user folder');
        return uploadedFile.id;
      }
    } catch (e) {
      //print('Error uploading image to user folder: $e');
      return null;
    }
  }

  // Create a folder in Google Drive
  Future<String?> createFolder(String folderName, {String? parentId}) async {
    try {
      if (_driveApi == null) {
        final initialized = await initialize();
        if (!initialized) return null;
      }

      final drive.File folderMetadata = drive.File()
        ..name = folderName
        ..mimeType = 'application/vnd.google-apps.folder'
        ..parents = parentId != null ? [parentId] : null;

      final drive.File folder = await _driveApi!.files.create(folderMetadata);
      return folder.id;
    } catch (e) {
      //print('Error creating folder: $e');
      return null;
    }
  }

  // Get or create the app's main folder structure
  Future<String?> getOrCreateAppFolders(String userId) async {
    try {
      // Step 1: Find or create main app folder
      String? appRootId = await findFolder(APP_ROOT_FOLDER);
      if (appRootId == null) {
        appRootId = await createFolder(APP_ROOT_FOLDER);
        if (appRootId == null) return null;
      }
      //print('App root folder ID: $appRootId');

      // Step 2: Find or create ProfileImages folder inside app folder
      String? profileFolderId = await findFolder(PROFILE_IMAGES_FOLDER, parentId: appRootId);
      if (profileFolderId == null) {
        profileFolderId = await createFolder(PROFILE_IMAGES_FOLDER, parentId: appRootId);
        if (profileFolderId == null) return null;
      }
      //print('Profile images folder ID: $profileFolderId');

      // Step 3: Find or create user-specific folder
      final userFolderName = '$USER_FOLDERS_PREFIX$userId';
      String? userFolderId = await findFolder(userFolderName, parentId: profileFolderId);
      if (userFolderId == null) {
        userFolderId = await createFolder(userFolderName, parentId: profileFolderId);
        if (userFolderId == null) return null;
      }
      //print('User folder ID: $userFolderId');

      return userFolderId;
    } catch (e) {
      //print('Error setting up folder structure: $e');
      return null;
    }
  }
  
  // Find folder by name in a specific parent (or root if parentId is null)
  Future<String?> findFolder(String folderName, {String? parentId}) async {
    try {
      if (_driveApi == null) return null;

      String query = "mimeType='application/vnd.google-apps.folder' and name='$folderName' and trashed=false";
      
      if (parentId != null) {
        query += " and '$parentId' in parents";
      }

      final drive.FileList result = await _driveApi!.files.list(
        q: query,
        spaces: 'drive',
      );

      if (result.files != null && result.files!.isNotEmpty) {
        return result.files!.first.id;
      }

      return null;
    } catch (e) {
      //print('Error finding folder: $e');
      return null;
    }
  }

  // Download image from Google Drive
  Future<Uint8List?> downloadImage(String fileId) async {
    try {
      if (_driveApi == null) {
        final initialized = await initialize();
        if (!initialized) return null;
      }

      final drive.Media media = await _driveApi!.files.get(
        fileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      final List<int> dataStore = [];
      await for (final data in media.stream) {
        dataStore.addAll(data);
      }

      return Uint8List.fromList(dataStore);
    } catch (e) {
      //print('Error downloading image: $e');
      return null;
    }
  }

  // Update/Replace existing image
  Future<String?> updateImage({
    required String fileId,
    required File newImageFile,
  }) async {
    try {
      if (_driveApi == null) {
        final initialized = await initialize();
        if (!initialized) return null;
      }

      final Uint8List imageBytes = await newImageFile.readAsBytes();
      final drive.Media media = drive.Media(
        Stream.value(imageBytes),
        imageBytes.length,
        contentType: _getContentType(newImageFile.path),
      );

      final drive.File updatedFile = await _driveApi!.files.update(
        drive.File(),
        fileId,
        uploadMedia: media,
      );

      return updatedFile.id;
    } catch (e) {
      //print('Error updating image: $e');
      return null;
    }
  }

  // Delete image from Google Drive
  Future<bool> deleteImage(String fileId) async {
    try {
      if (_driveApi == null) {
        final initialized = await initialize();
        if (!initialized) return false;
      }

      await _driveApi!.files.delete(fileId);
      return true;
    } catch (e) {
      //print('Error deleting image: $e');
      return false;
    }
  }

  // Get content type based on file extension
  String _getContentType(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  // Sign out from Google Drive
  Future<void> signOut() async {
    await _googleSignIn?.signOut();
    _driveApi = null;
  }
}