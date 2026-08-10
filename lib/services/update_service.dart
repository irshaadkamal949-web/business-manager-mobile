import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateService {
  // This points to the version.json file in your GitHub repository
  static const String versionCheckUrl = 'https://raw.githubusercontent.com/irshaadkamal949-web/business-manager-mobile/main/version.json';

  Future<UpdateInfo?> checkForUpdates() async {
    try {
      final response = await http.get(Uri.parse(versionCheckUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final latestVersion = data['version'] as String;
        final downloadUrl = data['download_url'] as String;

        final packageInfo = await PackageInfo.fromPlatform();
        final currentVersion = packageInfo.version;

        if (_isNewerVersion(currentVersion, latestVersion)) {
          return UpdateInfo(
            latestVersion: latestVersion,
            downloadUrl: downloadUrl,
          );
        }
      }
    } catch (e) {
      print("Error checking for updates: \$e");
    }
    return null;
  }

  bool _isNewerVersion(String current, String latest) {
    List<int> currentParts = current.split('.').map(int.parse).toList();
    List<int> latestParts = latest.split('.').map(int.parse).toList();

    for (int i = 0; i < currentParts.length; i++) {
      if (latestParts.length > i && latestParts[i] > currentParts[i]) {
        return true;
      } else if (latestParts.length > i && latestParts[i] < currentParts[i]) {
        return false;
      }
    }
    return false;
  }

  Future<void> launchUpdateUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      print("Could not launch update URL");
    }
  }
}

class UpdateInfo {
  final String latestVersion;
  final String downloadUrl;

  UpdateInfo({required this.latestVersion, required this.downloadUrl});
}
