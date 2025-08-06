// S:\Projects\gemma_final_app\lib\src\features\conditions\blind_assist\screens\model_management_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Adjusted imports for the new project structure
import 'package:gemma_final_app/src/features/conditions/blind_assist/services/gemma_service.dart';
import 'package:gemma_final_app/src/features/conditions/blind_assist/screens/assist_screen.dart';
import 'package:gemma_final_app/src/config/app_router.dart';

class ModelManagementScreen extends StatefulWidget {
  // NEW: Add a parameter to control automatic navigation.
  final bool isAutoNavigate;

  const ModelManagementScreen({super.key, this.isAutoNavigate = true});

  @override
  State<ModelManagementScreen> createState() => _ModelManagementScreenState();
}

class _ModelManagementScreenState extends State<ModelManagementScreen> {
  late GemmaService _gemmaService;

  String _statusMessage = "Checking for AI model...";
  double _downloadProgress = 0.0;
  bool _isProcessing = false;
  String _modelPath = "Initializing...";
  bool _isFileCheckComplete = false;
  bool _isDownloading = false;
  bool _cancelDownload = false;
  final TextEditingController _tokenController = TextEditingController();


  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isFileCheckComplete) {
      _gemmaService = Provider.of<GemmaService>(context, listen: false);
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

      // MODIFIED: Only navigate if isAutoNavigate is true AND model is installed.
      if (widget.isAutoNavigate && isInstalled) {
        _navigateToAssistScreen();
        return;
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

  void _navigateToAssistScreen() {
    // Using named route for consistency
    Navigator.of(context).pushReplacementNamed(AppRouter.blindAssistFunctionalityRoute);
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
    if (_isDownloading) return;

    final token = _tokenController.text.trim();
    if (token.isEmpty) {
      _showSnackBar("Please enter your Hugging Face token");
      return;
    }

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
      _statusMessage = "Starting download...";
    });

    try {
      await for (final progress in _gemmaService.downloadModel(authToken: token)) {
        if (mounted) {
          if(_cancelDownload) return;
          setState(() {
            _downloadProgress = progress;
            _statusMessage = "Downloading model: ${(progress * 100).toStringAsFixed(1)}%";
          });
        }
      }

      if (mounted) {
        _showSnackBar("Model downloaded successfully!");
        setState(() {
          _isDownloading = false;
          _downloadProgress = 0.0;
        });
        _checkInitialStatus();
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar("Download failed: ${e.toString()}");
        setState(() {
          _isDownloading = false;
          _downloadProgress = 0.0;
          _statusMessage = "Download failed. Please try again.";
        });
      }
    }
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
  void _cancelDownloadAction() {
    setState(() {
      _cancelDownload = true;
      _isDownloading = false;
      _statusMessage = "Download cancelled.";
      _downloadProgress = 0.0;
    });
    _showSnackBar("Download cancelled.");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Blind AI Model Setup')),
      body: !_isFileCheckComplete
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(_statusMessage, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              if (_isDownloading) ...[
                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        LinearProgressIndicator(value: _downloadProgress),
                        Container(
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white, size: 16),
                            onPressed: _cancelDownloadAction,
                            tooltip: 'Cancel Download',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text("${(_downloadProgress * 100).toStringAsFixed(1)}%", textAlign: TextAlign.center),
                const SizedBox(height: 20),
              ],
              const Text("Download Options:", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("To download the model:", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("1. Go to huggingface.co and create an account"),
                      Text("2. Accept the Gemma license terms"),
                      Text("3. Generate an access token in Settings"),
                      Text("4. Enter your token below:"),
                      SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _tokenController,
                decoration: const InputDecoration(
                  hintText: "hf_xxxxxxxxxxxxxxxxxxxxxxxxx",
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                obscureText: true,
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: (_isProcessing || _isDownloading) ? null : _downloadModel,
                icon: const Icon(Icons.download),
                label: const Text("Download Model"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: (_isProcessing || _isDownloading) ? null : _copyFromDownloads,
                icon: const Icon(Icons.file_copy),
                label: const Text("Copy from Downloads"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              ),
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