// lib/src/features/conditions/allergy_checker/services/camera_service.dart
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class AllergyCameraService {
  List<CameraDescription> _cameras = [];
  CameraController? _controller;
  bool _isInitialized = false;

  CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized;

  Future<void> initializeCamera() async {
    // If the controller is already initialized, just return.
    if (_isInitialized) {
      return;
    }

    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        throw Exception('No cameras found.');
      }

      // Select the first back camera
      final backCamera = _cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );

      _controller = CameraController(
        backCamera,
        ResolutionPreset.high,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();
      _isInitialized = true;
      print('DEBUG: Camera initialized successfully.');
    } catch (e) {
      _isInitialized = false;
      print('ERROR: Failed to initialize camera: $e');
      rethrow;
    }
  }

  Future<String?> takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      print('ERROR: Camera controller is not initialized.');
      return null;
    }

    if (_controller!.value.isTakingPicture) {
      print('INFO: Already taking a picture.');
      return null;
    }

    try {
      final XFile file = await _controller!.takePicture();
      return file.path;
    } on CameraException catch (e) {
      print('ERROR: Failed to take picture: $e');
      return null;
    }
  }

  Future<void> setFlashMode(FlashMode mode) async {
    if (_controller != null && _controller!.value.isInitialized) {
      await _controller!.setFlashMode(mode);
    }
  }

  // CRITICAL: This method needs to be robust and await the disposal
  Future<void> dispose() async {
    if (_controller != null) {
      print('DEBUG: Disposing camera controller...');
      await _controller!.dispose();
      _controller = null;
      _isInitialized = false;
      print('DEBUG: Camera controller disposed.');
    }
  }
}