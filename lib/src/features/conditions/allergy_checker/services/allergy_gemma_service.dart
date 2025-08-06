// lib/src/features/conditions/allergy_checker/services/allergy_gemma_service.dart
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_gemma/core/model.dart';
import 'package:flutter_gemma/core/message.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:image/image.dart' as img;

import 'package:gemma_final_app/src/features/conditions/blind_assist/constants.dart';
import 'package:gemma_final_app/src/shared/services/model_authenticated.dart';

class AllergyGemmaService {
  late final FlutterGemmaPlugin _gemma;
  String? _modelPath;

  InferenceModel? _gemmaModel;
  dynamic _gemmaChat;

  AllergyGemmaService() {
    _gemma = FlutterGemmaPlugin.instance;
  }

  bool get isModelInitialized => _gemmaChat != null;

  Future<String> getModelPath() async {
    return await _getPath();
  }

  Future<String> _getPath() async {
    if (_modelPath != null) return _modelPath!;
    final appDocDir = await getApplicationSupportDirectory();
    _modelPath = p.join(appDocDir.path, GEMMA_MODEL_FILENAME);
    return _modelPath!;
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

  Future<void> initializeModelFromLocalFile() async {
    final path = await _getPath();
    await _gemma.modelManager.setModelPath(path);
    if (!await _gemma.modelManager.isModelInstalled) {
      throw Exception("Model path set, but isModelInstalled reports false.");
    }
  }

  Future<void> initializeForImageChat() async {
    print("DEBUG: Calling initializeForImageChat...");
    final bool modelInstalled = await isModelInstalled();
    print("DEBUG: isModelInstalled reported: $modelInstalled");

    if (!modelInstalled) {
      // This is the most likely failure point. If the model file is there but not loaded.
      // We need to set the path first before trying to create the model.
      print("DEBUG: Model not installed. Attempting to set path and then create model.");
      await initializeModelFromLocalFile();
      // Re-check after setting the path
      if (!await isModelInstalled()) {
        throw Exception("Gemma model is not installed. Please complete the setup.");
      }
    }

    try {
      print("DEBUG: Creating multi-modal model...");
      _gemmaModel = await _gemma.createModel(
        modelType: ModelType.gemmaIt,
        maxTokens: 2048,
        supportImage: true,
      );
      print("DEBUG: Multi-modal model created successfully.");

      print("DEBUG: Creating multi-modal chat instance...");
      _gemmaChat = await _gemmaModel!.createChat(
        temperature: 0.2,
        randomSeed: 1,
        topK: 1,
        supportImage: true,
      );
      print("DEBUG: Multi-modal chat instance created successfully.");
    } catch (e) {
      print("ERROR: Failed to create Gemma model or chat instance: $e");
      // Re-throw the exception so the UI can catch it
      throw Exception("Failed to initialize Gemma for allergy checking: $e");
    }
  }

  Future<Map<String, dynamic>> checkImageForIngredients(String imagePath,
      List<String> userAllergens) async {
    if (!isModelInitialized) {
      throw Exception("Gemma chat is not initialized.");
    }

    try {
      final File imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        throw Exception("Image file not found at path: $imagePath");
      }

      final Uint8List imageBytes = await imageFile.readAsBytes();

      final img.Image? originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) {
        throw Exception("Failed to decode image.");
      }
      final img.Image resizedImage = img.copyResize(originalImage, width: 512);
      final Uint8List resizedImageBytes = Uint8List.fromList(
          img.encodeJpg(resizedImage));

      final String prompt = _buildAllergyPrompt(userAllergens);

      final Message message = Message.withImage(
        text: prompt,
        imageBytes: resizedImageBytes,
      );

      await _gemmaChat!.addQueryChunk(message);

      final responseStream = _gemmaChat!.generateChatResponseAsync();
      String fullResponse = "";

      await for (final token in responseStream) {
        if (token is TextResponse) {
          fullResponse += token.token;
        }
      }

      return _parseGemmaResponse(fullResponse, userAllergens);
    } catch (e, stackTrace) {
      print("ERROR in checkImageForIngredients: $e");
      print("Stack trace: $stackTrace");
      throw Exception("Failed to check for allergens: $e");
    }
  }

  String _buildAllergyPrompt(List<String> userAllergens) {
    return """
You are an intelligent allergy checker. Your task is to analyze the provided image, which contains a food product and its ingredients list.

1.  Read and identify all the ingredients from the image.
2.  Compare the ingredients you find with the following list of allergens: ${userAllergens
        .join(', ')}.
3.  Based on your analysis, determine if the product contains any of the user's allergens.
4.  Be concise.
5.  Limit your description to 2-4 sentences.
6.  Provide only the most important information directly.
7.  Provide a clear, structured JSON response with the following keys:
    -   `status`: A string, either "Safe" or "Alert". "Alert" if any of the user's allergens are found.
    -   `title`: A short, descriptive name for the product (e.g., "Chocolate Bar").
    -   `message`: A concise description of the findings. If safe, say "No allergens detected.". If an alert, list the allergens found and any other relevant warnings (e.g., "Contains dairy and may contain traces of nuts").
    -   `detected_allergens`: A list of strings containing only the allergens from the user's list that were actually detected in the product. If none, this should be an empty list.


Example of a "Safe" response:
{
  "status": "Safe",
  "title": "Apple",
  "message": "No allergens detected.",
  "detected_allergens": []
}
""";
  }

  Map<String, dynamic> _parseGemmaResponse(String response, List<String> userAllergens) {
    String cleanedResponse = response.trim();
    print("Gemma's raw response was: $cleanedResponse"); // Add this line for debugging

    // Handle cases where the model wraps the JSON in code fences.
    // This is more robust now to handle missing closing fences.
    final jsonMatch = RegExp(r'```json\s*(\{.*\})\s*```', multiLine: true, dotAll: true).firstMatch(cleanedResponse);
    if (jsonMatch != null && jsonMatch.group(1) != null) {
      cleanedResponse = jsonMatch.group(1)!.trim();
      print("JSON content extracted with regex: $cleanedResponse"); // Debugging
    } else if (cleanedResponse.startsWith('```json')) {
      // Handle cases where the closing fence is missing
      cleanedResponse = cleanedResponse.substring('```json'.length).trim();
      print("JSON content extracted by simple substring: $cleanedResponse"); // Debugging
    } else {
      // Assume it's a raw JSON response if no fences are present
      print("No JSON fences found, attempting to parse raw response.");
    }

    // Add an extra check to remove anything that might be after the JSON
    // The closing '}' might be followed by other text, this regex will
    // find the last valid JSON block.
    final jsonObjectMatch = RegExp(r'\{.*\}', multiLine: true, dotAll: true).firstMatch(cleanedResponse);
    if (jsonObjectMatch != null) {
      cleanedResponse = jsonObjectMatch.group(0)!;
    } else {
      // If we still can't find a JSON object, fall back to error state
      print("Failed to find a valid JSON object in the cleaned response.");
      return {
        "status": "Error",
        "title": "Scan Failed",
        "message": "Could not process the ingredients. Please try again.",
        "detected_allergens": [],
      };
    }

    try {
      final Map<String, dynamic> jsonResponse = jsonDecode(cleanedResponse);
      print("Successfully parsed JSON: $jsonResponse"); // Debugging
      return jsonResponse;
    } catch (e) {
      print("Failed to parse JSON response from Gemma: $e");
      return {
        "status": "Error",
        "title": "Scan Failed",
        "message": "Could not process the ingredients. Please try again.",
        "detected_allergens": [],
      };
    }
  }
}