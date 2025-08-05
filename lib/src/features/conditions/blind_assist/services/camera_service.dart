// lib/src/features/conditions/blind_assist/services/camera_service.dart

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

class CameraService {
  CameraController? _controller;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  CameraController? get controller => _controller;

  // This callback will be triggered whenever a new camera frame is available
  void Function(CameraImage)? onImageAvailable;

  Future<void> initialize(void Function(CameraImage) onImageAvailableCallback) async {
    this.onImageAvailable = onImageAvailableCallback;

    // Retrieve the list of available cameras
    final cameras = await availableCameras();

    // NEW: Add a debug print to see what cameras are found
    if (kDebugMode) { // Use kDebugMode to only run this in debug builds
      print("DEBUG: availableCameras() returned: ${cameras.length} cameras.");
      for (var camera in cameras) {
        print("DEBUG: Found camera: ${camera.name}, facing: ${camera.lensDirection}");
      }
    }

    // Check if any cameras were found
    if (cameras.isEmpty) {
      throw Exception('No cameras found.');
    }

    // Find the first available camera (usually the rear camera)
    final firstCamera = cameras.first;

    _controller = CameraController(
      firstCamera,
      ResolutionPreset.low, // Use a lower resolution to reduce processing load
      enableAudio: false, // We don't need audio for this app
    );

    // Initialize the controller
    await _controller!.initialize();

    // Start the image stream after initialization is complete
    await _controller!.startImageStream((image) {
      if (this.onImageAvailable != null) {
        this.onImageAvailable!(image);
      }
    });

    _isInitialized = true;
    if (kDebugMode) {
      print("DEBUG: CameraService initialized successfully.");
    }
  }

  // Dispose of the controller when not needed to release resources
  Future<void> dispose() async {
    _isInitialized = false;
    await _controller?.stopImageStream();
    await _controller?.dispose();
    _controller = null;
    if (kDebugMode) {
      print("DEBUG: CameraService disposed.");
    }
  }
}