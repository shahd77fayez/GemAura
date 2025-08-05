// lib/src/features/conditions/alzheimer_helper/services/alzheimer_gemma_service.dart

import 'dart:io';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_gemma/core/model.dart';
import 'package:flutter_gemma/core/message.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'package:gemma_final_app/src/features/conditions/blind_assist/constants.dart';

class AlzheimerGemmaService {
  late final FlutterGemmaPlugin _gemma;
  String? _modelPath;
  List<Message> _conversationHistory = [];

  AlzheimerGemmaService() {
    _gemma = FlutterGemmaPlugin.instance;
  }

  // Properties to check status
  dynamic get chatInstance => _gemmaChat;
  bool get isModelInitialized => _gemmaChat != null;
  List<Message> get conversationHistory => List.unmodifiable(_conversationHistory);

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

  Stream<double> downloadModel() {
    final controller = StreamController<double>();
    try {
      _gemma.modelManager.downloadModelFromNetworkWithProgress(GEMMA_MODEL_URL).listen(
            (progress) => controller.add(progress.toDouble()),
        onDone: () => controller.close(),
        onError: (e) => controller.addError("Download failed: $e"),
      );
    } catch (e) {
      controller.addError("Error starting download: $e");
      controller.close();
    }
    return controller.stream;
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
    print("DEBUG: AlzheimerGemmaService - isModelInstalled: $modelInstalled");

    if (!modelInstalled) {
      throw Exception("Gemma model is not installed. Please complete the setup screen.");
    }

    try {
      // Create model for text-only conversation (no image support needed for Alzheimer helper)
      _gemmaModel = await _gemma.createModel(
        modelType: ModelType.gemmaIt,
        maxTokens: 2048,
        supportImage: false, // Text-only for Alzheimer helper
      );
      print("DEBUG: AlzheimerGemmaModel created successfully for text-only chat.");

      // Create chat instance for text conversation
      _gemmaChat = await _gemmaModel!.createChat(
        temperature: 0.7, // Slightly lower temperature for more consistent responses
        randomSeed: 1,
        topK: 1,
        supportImage: false, // Text-only conversation
      );
      print("DEBUG: Alzheimer Gemma chat instance created successfully.");

      // Clear conversation history on new initialization
      _conversationHistory.clear();
    } catch (e) {
      print("ERROR: Failed to create Alzheimer Gemma model or chat instance: $e");
      throw e;
    }
  }

  // Generate response for memory assistant conversations
  Stream<dynamic> generateMemoryResponse(String userMessage) async* {
    if (!isModelInitialized) {
      throw Exception("Gemma chat is not initialized.");
    }

    try {
      // Create context-aware prompt for memory assistance
      final String contextPrompt = _buildMemoryAssistantPrompt(userMessage);

      print("DEBUG: Creating memory assistant message");

      // Create the message
      final Message message = Message(text: contextPrompt);

      // Add user message to conversation history
      _conversationHistory.add(Message(text: userMessage));

      // Add the query chunk
      await _gemmaChat!.addQueryChunk(message);

      print("DEBUG: Memory assistant message added to chat, generating response...");

      // Generate and stream the response
      final responseStream = _gemmaChat!.generateChatResponseAsync();
      String fullResponse = "";

      await for (final token in responseStream) {
        yield token;

        // Collect full response for conversation history
        if (token is TextResponse) {
          String cleanedToken = _cleanResponseToken(token.token);
          if (!_isEndOfTurnToken(token.token)) {
            fullResponse += cleanedToken;
          }
        }
      }

      // Add assistant response to conversation history
      if (fullResponse.trim().isNotEmpty) {
        _conversationHistory.add(Message(text: fullResponse.trim()));
      }

    } catch (e, stackTrace) {
      print("ERROR in generateMemoryResponse: $e");
      print("Stack trace: $stackTrace");
      throw Exception("Failed to generate memory response: $e");
    }
  }

  String _buildMemoryAssistantPrompt(String userMessage) {
    // Build context from recent conversation history
    String conversationContext = "";
    if (_conversationHistory.isNotEmpty) {
      conversationContext = "\n\nRecent conversation:\n";
      // Only include last 4 messages to avoid token limit
      final recentMessages = _conversationHistory.take(4).toList();
      for (int i = 0; i < recentMessages.length; i++) {
        final isUser = i % 2 == 0;
        conversationContext += "${isUser ? 'User' : 'Assistant'}: ${recentMessages[i].text}\n";
      }
    }

    return """You are a compassionate memory assistant for someone who may have memory challenges. Your role is to:

1. Help them remember important information (appointments, medications, people, etc.)
2. Provide gentle reminders without being patronizing
3. Assist with daily tasks and routines
4. Offer emotional support and encouragement
5. Help organize thoughts and memories

Guidelines:
- Be patient, kind, and understanding
- Use simple, clear language
- Provide practical, actionable advice
- Celebrate small victories
- Never make the person feel bad about forgetting
- Keep responses concise (2-3 sentences max)
- Focus on being helpful rather than diagnostic

$conversationContext

User's current message: $userMessage

Please respond as their supportive memory assistant:""";
  }

  String _cleanResponseToken(String token) {
    String cleaned = token
        .replaceAll('<end_of_turn>', '')
        .replaceAll('</end_of_turn>', '')
        .replaceAll('<|end_of_turn|>', '')
        .replaceAll('[end_of_turn]', '')
        .replaceAll('<start_of_turn>', '')
        .replaceAll('<|start_of_turn|>', '')
        .replaceAll('<|im_start|>', '')
        .replaceAll('<|im_end|>', '')
        .replaceAll('<system>', '')
        .replaceAll('</system>', '')
        .replaceAll('<model>', '')
        .replaceAll('</model>', '')
        .replaceAll('<user>', '')
        .replaceAll('</user>', '')
        .replaceAll('<assistant>', '')
        .replaceAll('</assistant>', '')
        .replaceAll(RegExp(r'<[^>]*>'), '');

    return cleaned;
  }

  bool _isEndOfTurnToken(String token) {
    final endTokens = [
      '<end_of_turn>',
      '</end_of_turn>',
      '<|end_of_turn|>',
      '[end_of_turn]',
      'end_of_turn',
    ];

    String lowerToken = token.toLowerCase();

    for (String endToken in endTokens) {
      if (lowerToken.contains(endToken.toLowerCase())) {
        return true;
      }
    }

    return lowerToken.startsWith('<end_of_turn>') ||
        lowerToken.startsWith('<|end_of_turn|>') ||
        lowerToken.startsWith('[end_of_turn]');
  }

  // Clear conversation history
  void clearConversation() {
    _conversationHistory.clear();
  }

  // Get conversation summary for memory aids
  String getConversationSummary() {
    if (_conversationHistory.isEmpty) return "No conversation yet.";

    final lastFewMessages = _conversationHistory.take(6).toList();
    String summary = "Recent conversation highlights:\n";

    for (int i = 0; i < lastFewMessages.length; i++) {
      final isUser = i % 2 == 0;
      final prefix = isUser ? "You said" : "I helped with";
      summary += "• $prefix: ${lastFewMessages[i].text.substring(0,
          lastFewMessages[i].text.length > 50 ? 50 : lastFewMessages[i].text.length)}...\n";
    }

    return summary;
  }
}