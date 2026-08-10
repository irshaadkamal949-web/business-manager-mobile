import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}

class GoogleDriveService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      drive.DriveApi.driveScope, 
    ],
  );

  GoogleSignInAccount? _currentUser;
  drive.DriveApi? _driveApi;

  Future<bool> signIn() async {
    try {
      _currentUser = await _googleSignIn.signIn();
      if (_currentUser == null) return false;

      final headers = await _currentUser!.authHeaders;
      final authenticateClient = GoogleAuthClient(headers);
      _driveApi = drive.DriveApi(authenticateClient);
      
      return true;
    } catch (e) {
      print("Google Sign In Error: $e");
      return false;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _currentUser = null;
    _driveApi = null;
  }

  Future<drive.File?> _findDatabaseFile(String fileName) async {
    if (_driveApi == null) throw Exception("Not signed in");

    // Find the file by name
    final fileList = await _driveApi!.files.list(
      q: "name = '$fileName' and trashed = false",
      $fields: "files(id, name, modifiedTime)",
    );

    if (fileList.files != null && fileList.files!.isNotEmpty) {
      return fileList.files!.first;
    }
    return null;
  }

  Future<bool> downloadDatabase(String dbName) async {
    if (_driveApi == null) throw Exception("Not signed in");

    final driveFile = await _findDatabaseFile(dbName);
    if (driveFile == null || driveFile.id == null) {
      throw Exception("Database '$dbName' not found on Google Drive.");
    }

    final drive.Media media = await _driveApi!.files.get(
      driveFile.id!,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;

    final dbPath = await getDatabasesPath();
    final localPath = path.join(dbPath, dbName);
    final localFile = File(localPath);

    List<int> bytes = [];
    await media.stream.forEach((chunk) {
      bytes.addAll(chunk);
    });
    await localFile.writeAsBytes(bytes, flush: true);
    
    return true;
  }

  Future<bool> uploadDatabase(String dbName) async {
    if (_driveApi == null) throw Exception("Not signed in");

    final dbPath = await getDatabasesPath();
    final localPath = path.join(dbPath, dbName);
    final localFile = File(localPath);

    if (!await localFile.exists()) {
      throw Exception("Local database does not exist on your phone.");
    }

    final driveFile = await _findDatabaseFile(dbName);
    final media = drive.Media(localFile.openRead(), localFile.lengthSync());

    if (driveFile != null && driveFile.id != null) {
      // Update existing file
      final updateFile = drive.File();
      await _driveApi!.files.update(
        updateFile,
        driveFile.id!,
        uploadMedia: media,
      );
    } else {
      // Create new file
      final newFile = drive.File()..name = dbName;
      await _driveApi!.files.create(
        newFile,
        uploadMedia: media,
      );
    }
    return true;
  }
}
