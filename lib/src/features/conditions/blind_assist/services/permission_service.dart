// lib/services/permission_service.dart

import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestAll() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.microphone,
      Permission.speech,
      Permission.storage,
      if (Platform.isAndroid) Permission.manageExternalStorage,
    ].request();

    // Check if all essential permissions are granted
    bool allGranted = statuses.values.every((status) => status.isGranted);

    if (!allGranted) {
      print("Required permissions not granted. App may not function correctly.");
    }

    return allGranted;
  }
}