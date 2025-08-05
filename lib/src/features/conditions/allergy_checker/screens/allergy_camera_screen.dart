// lib/src/features/conditions/allergy_checker/screens/allergy_camera_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';

import 'package:gemma_final_app/src/config/theme.dart';
import 'package:gemma_final_app/src/features/conditions/allergy_checker/services/camera_service.dart';
import 'package:gemma_final_app/src/features/conditions/allergy_checker/services/allergy_gemma_service.dart';
import 'package:gemma_final_app/src/features/conditions/allergy_checker/screens/allergy_result_screen.dart'; // Import the new screen

class AllergyCameraScreen extends StatefulWidget {
  final List<String> userAllergens;

  const AllergyCameraScreen({
    super.key,
    required this.userAllergens,
  });

  @override
  State<AllergyCameraScreen> createState() => _AllergyCameraScreenState();
}

class _AllergyCameraScreenState extends State<AllergyCameraScreen> {
  // Use late final for the service, it will be instantiated in initState
  late final AllergyCameraService _cameraService;
  late final AllergyGemmaService _gemmaService;

  bool _isInitializing = true;
  bool _isProcessing = false;
  String? _errorMessage;
  FlashMode _currentFlashMode = FlashMode.off;

  @override
  void initState() {
    super.initState();
    _cameraService = AllergyCameraService();
    _initializeCamera();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _gemmaService = Provider.of<AllergyGemmaService>(context, listen: false);
  }

  Future<void> _initializeCamera() async {
    try {
      await _cameraService.initializeCamera();
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _takePictureAndAnalyze() async {
    // ... (This function is unchanged from our last fix)
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final String? imagePath = await _cameraService.takePicture();

      if (imagePath == null) {
        throw Exception('Failed to capture image');
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(width: 16),
              Text('Analyzing ingredients...'),
            ],
          ),
          duration: Duration(seconds: 30),
        ),
      );

      final Map<String, dynamic> result = await _gemmaService.checkImageForIngredients(
        imagePath,
        widget.userAllergens,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AllergyResultScreen(
            imagePath: imagePath,
            analysisResult: result,
            userAllergens: widget.userAllergens,
          ),
        ),
      );

    } catch (e) {
      print('Error during capture and analysis: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.alertRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _toggleFlash() async {
    // ... (This function is unchanged)
    try {
      FlashMode newMode;
      switch (_currentFlashMode) {
        case FlashMode.off:
          newMode = FlashMode.auto;
          break;
        case FlashMode.auto:
          newMode = FlashMode.always;
          break;
        case FlashMode.always:
          newMode = FlashMode.off;
          break;
        default:
          newMode = FlashMode.off;
      }

      await _cameraService.setFlashMode(newMode);
      setState(() {
        _currentFlashMode = newMode;
      });
    } catch (e) {
      print('Error toggling flash: $e');
    }
  }

  IconData _getFlashIcon() {
    // ... (This function is unchanged)
    switch (_currentFlashMode) {
      case FlashMode.off:
        return Icons.flash_off;
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.always:
        return Icons.flash_on;
      default:
        return Icons.flash_off;
    }
  }

  @override
  void dispose() {
    // This is the CRITICAL change:
    // Call the async dispose method without `await`.
    // The native call will be initiated, but the parent widget
    // can continue to be disposed without waiting, preventing the crash.
    _cameraService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ... (This entire build method is unchanged)
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Scan Food Label',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(_getFlashIcon(), color: Colors.white),
            onPressed: _toggleFlash,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // ... (This entire build method is unchanged)
    if (_isInitializing) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Initializing camera...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Camera Error',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        Positioned.fill(
          child: _cameraService.controller != null
              ? CameraPreview(_cameraService.controller!)
              : const Center(
            child: Text(
              'Camera not available',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        Positioned.fill(
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: const SafeArea(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 60),
                          Text(
                            'Position the food label or ingredients list in the center of the frame',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Make sure the text is clear and well-lit',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.width * 0.6,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.allergyPrimary,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        'Align ingredients list here',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _isProcessing ? null : _takePictureAndAnalyze,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isProcessing
                                ? Colors.grey
                                : AppColors.allergyPrimary,
                            border: Border.all(
                              color: Colors.white,
                              width: 4,
                            ),
                          ),
                          child: _isProcessing
                              ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          )
                              : const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _isProcessing ? 'Processing...' : 'Tap to scan',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
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
      ],
    );
  }
}