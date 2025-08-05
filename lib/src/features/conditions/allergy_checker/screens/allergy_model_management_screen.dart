// lib/src/features/conditions/allergy_checker/screens/allergy_model_management_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:gemma_final_app/src/features/conditions/allergy_checker/services/allergy_gemma_service.dart';
import 'package:gemma_final_app/src/config/app_router.dart';

class AllergyModelManagementScreen extends StatefulWidget {
  final bool isAutoNavigate;

  const AllergyModelManagementScreen({super.key, this.isAutoNavigate = true});

  @override
  State<AllergyModelManagementScreen> createState() => _AllergyModelManagementScreenState();
}

class _AllergyModelManagementScreenState extends State<AllergyModelManagementScreen> {
  late AllergyGemmaService _gemmaService;

  String _statusMessage = "Checking for AI model...";
  bool _isProcessing = false;
  String _modelPath = "Initializing...";
  bool _isFileCheckComplete = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isFileCheckComplete) {
      _gemmaService = Provider.of<AllergyGemmaService>(context, listen: false);
      _checkInitialStatus();
    }
  }

  Future<void> _checkInitialStatus() async {
    try {
      final path = await _gemmaService.getModelPath();
      if (!mounted) return;
      setState(() {
        _modelPath = path;
      });

      // First, check if the model file exists. This is a prerequisite.
      final fileExists = await _gemmaService.doesModelFileExist();

      if (!fileExists) {
        setState(() {
          _statusMessage = "AI Model not found. Please push it via ADB or download it.";
          _isFileCheckComplete = true;
        });
        return; // Exit if file doesn't exist
      }

      // If the file exists, we try to initialize it.
      await _gemmaService.initializeModelFromLocalFile();
      final isInstalled = await _gemmaService.isModelInstalled();

      if (widget.isAutoNavigate && isInstalled) {
        if (mounted) {
          Navigator.of(context).pop(true);
          return;
        }
      }

      if (mounted) {
        setState(() {
          if (isInstalled) {
            _statusMessage = "Model is installed and ready. You can go back.";
          } else {
            _statusMessage = "Model file found but not installed. Tap 'Initialize' to install.";
          }
          _isFileCheckComplete = true;
        });
      }
    } catch (e, stackTrace) {
      print("Error during initial status check: $e");
      if (mounted) {
        setState(() {
          _statusMessage = "Error initializing app. Please restart.";
          _isFileCheckComplete = true;
        });
        _showSnackBar("Initialization failed: ${e.toString()}");
      }
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<void> _handleAction(Future<void> Function() action, String processingMessage) async {
    if (_isProcessing) return;
    setState(() {
      _isProcessing = true;
      _statusMessage = processingMessage;
    });

    try {
      await action();
      _showSnackBar("Action successful!");
    } catch (e, stackTrace) {
      print("Error during action '$processingMessage': $e");
      _showSnackBar("Error: ${e.toString()}");
      setState(() {
        _statusMessage = "An error occurred. Please try again.";
      });
    } finally {
      if (mounted) {
        setState(() { _isProcessing = false; });
        _checkInitialStatus();
      }
    }
  }

  Future<void> _initializeModel() async {
    await _handleAction(
      _gemmaService.initializeForImageChat,
      "Initializing AI model...",
    );
  }

  Future<void> _copyFromDownloads() async {
    await _handleAction(
          () => Future.delayed(Duration(seconds: 1)),
      "Copying model from Downloads...",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Allergy AI Model Setup')),
      body: !_isFileCheckComplete
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(_statusMessage, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              const SizedBox(height: 40),
              const Text("Manual Setup:", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ListTile(
                title: const Text("Push 'gemma.task' via ADB to:"),
                subtitle: SelectableText(
                  _modelPath,
                  style: const TextStyle(fontFamily: 'monospace'),
                  maxLines: 2,
                ),
                leading: const Icon(Icons.folder_open),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _isProcessing ? null : _initializeModel,
                icon: const Icon(Icons.play_arrow),
                label: const Text("Initialize After Push"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            ],
          ),
        ),
      ),
    );
  }
}