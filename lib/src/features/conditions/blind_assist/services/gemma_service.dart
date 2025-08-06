//lib\src\features\conditions\blind_assist\services\gemma_service.dart

import 'dart:io';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_gemma/core/model.dart';
import 'package:flutter_gemma/core/message.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../../../shared/services/model_authenticated.dart';
import '../constants.dart';

class GemmaService {
  late final FlutterGemmaPlugin _gemma;
  String? _modelPath;

  GemmaService() {
    _gemma = FlutterGemmaPlugin.instance;
  }

  // Properties to check status
  dynamic get chatInstance => _gemmaChat;
  bool get isModelInitialized => _gemmaChat != null;

  InferenceModel? _gemmaModel;
  dynamic _gemmaChat;

  // Private method to safely initialize the path only ONCE.
  Future<String> _getPath() async {
    if (_modelPath != null) return _modelPath!;
    final appDocDir = await getApplicationSupportDirectory();
    _modelPath = p.join(appDocDir.path, GEMMA_MODEL_FILENAME);
    return _modelPath!;
  }

  Future<String> getModelPath() async {
    return await _getPath();
  }

  Future<bool> isModelInstalled() async {
    return await _gemma.modelManager.isModelInstalled;
  }

  Future<bool> doesModelFileExist() async {
    final path = await _getPath();
    return await File(path).exists();
  }

  Stream<double> downloadModel({String? authToken}) async* {
    try {
      final path = await _getPath();

      // Use the authenticated download service
      await for (final progress in AuthenticatedDownloadService.downloadWithAuth(
        url: GEMMA_MODEL_URL,
        destinationPath: path,
        authToken: authToken,
      )) {
        yield progress;
      }

      // After download, set the model path in the Flutter Gemma plugin
      await _gemma.modelManager.setModelPath(path);

    } catch (e) {
      throw Exception("Download failed: $e");
    }
  }

  Future<void> initializeModelFromLocalFile() async {
    final path = await _getPath();
    print("Attempting to set model path with ModelFileManager: $path");
    await _gemma.modelManager.setModelPath(path);

    if (!await _gemma.modelManager.isModelInstalled) {
      throw Exception("Model path set, but isModelInstalled reports false.");
    }
  }

  Future<void> copyModelFromDownloads() async {
    final path = await _getPath();
    final Directory downloadDir = Directory('/storage/emulated/0/Download');
    final File externalModelFile = File(p.join(downloadDir.path, GEMMA_MODEL_FILENAME));

    if (!await externalModelFile.exists()) {
      throw Exception("Model not found in /sdcard/Download folder.");
    }

    final internalModelFile = File(path);
    if (await internalModelFile.exists()) {
      await internalModelFile.delete();
    }
    await externalModelFile.copy(internalModelFile.path);
  }

  Future<void> initializeForChat() async {
    final bool modelInstalled = await isModelInstalled();
    print("DEBUG: GemmaService - isModelInstalled: $modelInstalled");

    if (!modelInstalled) {
      throw Exception("Gemma model is not installed. Please complete the setup screen.");
    }

    try {
      // CRITICAL: Ensure image support is enabled
      _gemmaModel = await _gemma.createModel(
        modelType: ModelType.gemmaIt,
        maxTokens: 2048,
        supportImage: true, // This is crucial for vision
      );
      print("DEBUG: GemmaModel created successfully with image support.");

      // CRITICAL: Create chat with image support
      _gemmaChat = await _gemmaModel!.createChat(
        temperature: 0.8,
        randomSeed: 1,
        topK: 1,
        supportImage: true, // This is crucial for vision
      );
      print("DEBUG: Gemma chat instance created successfully with image support.");
    } catch (e) {
      print("ERROR: Failed to create Gemma model or chat instance: $e");
      throw e;
    }
  }

  // FIXED: This method now properly handles multimodal messages
  Stream<dynamic> generateResponse(String prompt, {List<int>? imageBytes}) async* {
    if (!isModelInitialized) {
      throw Exception("Gemma chat is not initialized.");
    }

    try {
      // Create the message with proper structure
      final Message message;

      if (imageBytes != null) {
        print("DEBUG: Creating multimodal message with image (${imageBytes.length} bytes)");
        // CRITICAL: Create message with BOTH text and image
        message = Message(
          text: prompt,
          imageBytes: Uint8List.fromList(imageBytes),
          // Ensure this is marked as user input
        );
      } else {
        print("DEBUG: Creating text-only message");
        message = Message(text: prompt);
      }

      // Add the query chunk
      await _gemmaChat!.addQueryChunk(message);

      print("DEBUG: Message added to chat, generating response...");

      // Generate and stream the response
      final responseStream = _gemmaChat!.generateChatResponseAsync();

      await for (final token in responseStream) {
        yield token;
      }

    } catch (e, stackTrace) {
      print("ERROR in generateResponse: $e");
      print("Stack trace: $stackTrace");
      throw Exception("Failed to generate response: $e");
    }
  }

  // Alternative method that matches your current usage pattern
  Stream<dynamic> generateResponseFromMessage(Message message) async* {
    if (!isModelInitialized) {
      throw Exception("Gemma chat is not initialized.");
    }

    try {
      print("DEBUG: Processing message - Has image: ${message.imageBytes != null}");
      if (message.imageBytes != null) {
        print("DEBUG: Image bytes length: ${message.imageBytes!.length}");
      }

      await _gemmaChat!.addQueryChunk(message);

      final responseStream = _gemmaChat!.generateChatResponseAsync();

      await for (final token in responseStream) {
        yield token;
      }

    } catch (e, stackTrace) {
      print("ERROR in generateResponseFromMessage: $e");
      print("Stack trace: $stackTrace");
      throw Exception("Failed to generate response: $e");
    }
  }
}