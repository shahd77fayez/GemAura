// lib/src/features/conditions/alzheimer_helper/screens/model_management_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Adjusted imports for the new project structure
import 'package:gemma_final_app/src/features/conditions/alzheimer_helper/services/alzheimer_gemma_service.dart';
import 'package:gemma_final_app/src/features/conditions/screens/alzheimer_helper_screen.dart'; // We'll navigate back to this screen
import 'package:gemma_final_app/src/config/app_router.dart';

class AlzheimerModelManagementScreen extends StatefulWidget {
  final bool isAutoNavigate;

  const AlzheimerModelManagementScreen({super.key, this.isAutoNavigate = true});

  @override
  State<AlzheimerModelManagementScreen> createState() => _AlzheimerModelManagementScreenState();
}

class _AlzheimerModelManagementScreenState extends State<AlzheimerModelManagementScreen> {
  late AlzheimerGemmaService _gemmaService;

  String _statusMessage = "Checking for AI model...";
  double _downloadProgress = 0.0;
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
      _gemmaService = Provider.of<AlzheimerGemmaService>(context, listen: false);
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

      final isInstalled = await _gemmaService.isModelInstalled();

      // NEW: Automatically go back to the previous screen (AlzheimerHelperScreen)
      // if the model is installed, rather than replacing the route.
      if (widget.isAutoNavigate && isInstalled) {
        if (mounted) {
          Navigator.of(context).pop();
          return;
        }
      }

      final fileExists = await _gemmaService.doesModelFileExist();
      if (mounted) {
        setState(() {
          _statusMessage = fileExists
              ? "Model file found. Tap 'Initialize' to install."
              : "AI Model not found. Please download it or push it via ADB.";
          _isFileCheckComplete = true;
        });
      }
    } catch (e, stackTrace) {
      print("Error during initial status check: $e");
      print("Stack Trace: $stackTrace");
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
      _downloadProgress = 0.0;
    });

    try {
      await action();
    } catch (e, stackTrace) {
      print("Error during action '$processingMessage': $e");
      print("Stack Trace: $stackTrace");
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

  Future<void> _downloadModel() async {
    if (_isProcessing) return;
    setState(() {
      _isProcessing = true;
      _downloadProgress = 0.0;
      _statusMessage = "Starting download...";
    });

    _gemmaService.downloadModel().listen(
          (progress) {
        if (mounted) {
          setState(() {
            _downloadProgress = progress;
            _statusMessage = "Downloading model (${progress.toStringAsFixed(1)}%)...";
          });
        }
      },
      onDone: () {
        if (mounted) {
          _showSnackBar("Download complete! Initializing...");
          _initializeModel();
        }
      },
      onError: (e, stackTrace) {
        print("Download error: $e");
        print("Stack Trace: $stackTrace");
        if (mounted) {
          _showSnackBar("Download failed: ${e.toString()}");
          setState(() {
            _isProcessing = false;
            _statusMessage = "Download failed. Please try again.";
          });
        }
      },
      cancelOnError: true,
    );
  }

  Future<void> _initializeModel() async {
    await _handleAction(
      _gemmaService.initializeModelFromLocalFile,
      "Installing AI model...",
    );
  }

  Future<void> _copyFromDownloads() async {
    await _handleAction(
      _gemmaService.copyModelFromDownloads,
      "Copying model from Downloads...",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alzheimer AI Model Setup')),
      body: !_isFileCheckComplete
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView( // NEW: Wrap the body in a SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(_statusMessage, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              if (_isProcessing && _downloadProgress > 0)
                LinearProgressIndicator(value: _downloadProgress / 100.0),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _isProcessing ? null : _downloadModel,
                icon: const Icon(Icons.download),
                label: Text(_isProcessing ? "Processing..." : "Download AI Model"),
              ),
              const SizedBox(height: 40),
              const Text("For Manual Setup:", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
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
                onPressed: _isProcessing ? null : _copyFromDownloads,
                icon: const Icon(Icons.copy),
                label: const Text("Copy from Downloads Folder"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _isProcessing ? null : _initializeModel,
                icon: const Icon(Icons.play_arrow),
                label: const Text("Initialize After Push/Copy"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            ],
          ),
        ),
      ),
    );
  }
}