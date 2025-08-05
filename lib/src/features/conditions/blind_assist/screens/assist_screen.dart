// S:\Projects\gemma_final_app\lib\src\features\conditions\blind_assist\screens\assist_screen.dart

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_gemma/core/message.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart'; // NEW: Import Provider

// Corrected absolute imports for services and screens based on your project structure
import 'package:gemma_final_app/src/features/conditions/blind_assist/services/camera_service.dart';
import 'package:gemma_final_app/src/features/conditions/blind_assist/services/gemma_service.dart';
import 'package:gemma_final_app/src/api/stt_service.dart'; // Corrected path as per main.dart
import 'package:gemma_final_app/src/api/tts_service.dart'; // Corrected path as per main.dart
import 'package:gemma_final_app/src/features/conditions/blind_assist/utils/image_converter.dart'; // Corrected path
import 'package:gemma_final_app/src/features/conditions/blind_assist/screens/model_management_screen.dart'; // Corrected path
import 'package:gemma_final_app/src/config/app_router.dart'; // NEW: Import AppRouter for navigation


class AssistScreen extends StatefulWidget {
  const AssistScreen({super.key});

  @override
  State<AssistScreen> createState() => _AssistScreenState();
}

class _AssistScreenState extends State<AssistScreen> {
  // Services - Declared late, will be initialized in didChangeDependencies
  late CameraService _cameraService;
  late GemmaService _gemmaService;
  late TtsService _ttsService;
  late SttService _sttService;

  // State
  final ValueNotifier<String> _assistantResponse = ValueNotifier("Initializing...");
  final ScrollController _scrollController = ScrollController();
  CameraImage? _lastCameraImage;
  bool _isFullyInitialized = false;


  @override
  void initState() {
    super.initState();
    // _initializeApp() will now be called in didChangeDependencies
    // to ensure Provider is ready.
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get service instances from the Provider tree
    // We use listen: false because we only need to read the service once,
    // not rebuild the widget when the service instance itself changes (which it shouldn't).
    _cameraService = Provider.of<CameraService>(context, listen: false);
    _gemmaService = Provider.of<GemmaService>(context, listen: false);
    _ttsService = Provider.of<TtsService>(context, listen: false);
    _sttService = Provider.of<SttService>(context, listen: false);

    // Call initialization logic only once after services are available
    if (!_isFullyInitialized) { // Prevent multiple initializations on rebuilds
      _initializeApp();
    }
  }

  Future<void> _initializeApp() async {
    try {
      // Services are now provided, so we can call their initialize methods
      await _ttsService.initialize();
      await _sttService.initialize(onResult: (result) {
        // Handle STT results if needed
      });

      // Initialize camera and Gemma in parallel
      await Future.wait([
        _cameraService.initialize((image) {
          _lastCameraImage = image;
          print("DEBUG: Camera image received. Format: ${image.format.group}, ${image.width}x${image.height}");
        }),
        _gemmaService.initializeForChat(),
      ]);

      if (mounted) {
        setState(() => _isFullyInitialized = true);
        _setResponseAndSpeak("I'm ready to help you see.");
      }
    } catch (e, stackTrace) {
      print("CRITICAL ERROR during initialization: $e");
      print("Stack Trace: $stackTrace");
      if (mounted) {
        _setResponseAndSpeak("Setup failed. Returning to model management.");
        await Future.delayed(const Duration(seconds: 3));
        if (mounted) {
          // Use named route for consistency
          Navigator.of(context).pushReplacementNamed(AppRouter.modelManagementRoute); // Assuming you add this route in app_router.dart
          // If you don't add a specific route for ModelManagementScreen, keep the MaterialPageRoute:
          // Navigator.of(context).pushReplacement(
          //   MaterialPageRoute(builder: (_) => const ModelManagementScreen()),
          // );
        }
      }
    }
  }

  void _setResponseAndSpeak(String text) {
    _assistantResponse.value = text;
    _ttsService.speak(text);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  bool _isVisionRequest(String command) {
    final lowerCommand = command.toLowerCase();

    // Direct vision keywords
    final visionKeywords = [
      'see', 'look', 'view', 'watch', 'observe', 'spot', 'notice',
      'describe', 'tell me about', 'what is', 'what\'s', 'whats',
      'show me', 'identify', 'recognize', 'find', 'locate'
    ];

    // Location/direction phrases
    final locationPhrases = [
      'in front of me', 'ahead of me', 'before me', 'facing me',
      'in front', 'ahead', 'forward', 'there', 'here',
      'around me', 'nearby', 'close', 'near me',
      'to my left', 'to my right', 'left side', 'right side',
      'above me', 'below me', 'up there', 'down there'
    ];

    // Common vision request patterns
    final visionPatterns = [
      'what do you see',
      'what can you see',
      'describe what you see',
      'tell me what you see',
      'what is in front of me',
      'what\'s in front of me',
      'whats in front of me',
      'what is ahead of me',
      'what\'s ahead of me',
      'whats ahead of me',
      'what is there',
      'what\'s there',
      'whats there',
      'what is here',
      'what\'s here',
      'whats here',
      'look around',
      'look ahead',
      'look forward',
      'scan the area',
      'check what\'s ahead',
      'check whats ahead',
      'help me see',
      'i need to see',
      'i want to see',
      'can you see',
      'do you see',
      'is there anything',
      'are there any',
      'what objects',
      'any obstacles',
      'any people',
      'what\'s around',
      'whats around',
      'describe the scene',
      'describe my surroundings',
      'tell me about my surroundings',
      'what am i looking at',
      'what\'s in my view',
      'whats in my view'
    ];

    // Check for exact pattern matches first (most reliable)
    for (final pattern in visionPatterns) {
      if (lowerCommand.contains(pattern)) {
        print("DEBUG: Vision request detected via pattern: '$pattern'");
        return true;
      }
    }

    // Check for keyword + location combinations
    for (final keyword in visionKeywords) {
      if (lowerCommand.contains(keyword)) {
        for (final location in locationPhrases) {
          if (lowerCommand.contains(location)) {
            print("DEBUG: Vision request detected via keyword '$keyword' + location '$location'");
            return true;
          }
        }
        // Some keywords are strong indicators on their own
        if (['describe', 'identify', 'recognize', 'spot', 'observe'].contains(keyword)) {
          print("DEBUG: Vision request detected via strong keyword: '$keyword'");
          return true;
        }
      }
    }

    // Question patterns that likely need vision
    final questionPatterns = [
      RegExp(r'\bwhat.*(is|are).*(there|here|ahead|front)', caseSensitive: false),
      RegExp(r'\bcan you (see|find|spot|identify)', caseSensitive: false),
      RegExp(r'\bdo you (see|notice|spot)', caseSensitive: false),
      RegExp(r'\bis there (any|a|some)', caseSensitive: false),
      RegExp(r'\bare there (any|some)', caseSensitive: false),
      RegExp(r'\bhow many.*do you see', caseSensitive: false),
      RegExp(r'\bwhere (is|are)', caseSensitive: false),
    ];

    for (final pattern in questionPatterns) {
      if (pattern.hasMatch(lowerCommand)) {
        print("DEBUG: Vision request detected via regex pattern: ${pattern.pattern}");
        return true;
      }
    }

    print("DEBUG: No vision request detected in: '$command'");
    return false;
  }

  Future<void> _processCommand(String command) async {
    await _ttsService.stop();

    if (command.toLowerCase().contains("stop speaking")) {
      _setResponseAndSpeak("Speaking stopped.");
      return;
    }

    bool wantsDescription = _isVisionRequest(command);

    if (wantsDescription && _lastCameraImage == null) {
      _setResponseAndSpeak("Camera isn't ready yet. Please wait a moment.");
      print("DEBUG: _lastCameraImage is null, cannot process vision request.");
      return;
    }

    _setResponseAndSpeak("Processing your request...");
    print("DEBUG: User command: $command");
    print("DEBUG: Detected as vision request: $wantsDescription");

    try {
      if (wantsDescription) {
        await _processVisionCommand(command);
      } else {
        await _processTextCommand(command);
      }
    } catch (e, stackTrace) {
      print("ERROR processing command: $e");
      print("Stack Trace: $stackTrace");
      _setResponseAndSpeak("Sorry, an error occurred. Please try again.");
    }
  }

  Future<void> _processVisionCommand(String command) async {
    print("DEBUG: Processing vision command with camera image");
    print("DEBUG: _lastCameraImage format: ${_lastCameraImage?.format.group}");

    final imageBytes = await convertCameraImageToUint8List(_lastCameraImage!);
    if (imageBytes == null) {
      _setResponseAndSpeak("I'm having trouble processing the camera view.");
      print("ERROR: Image conversion returned null.");
      return;
    }

    print("DEBUG: Image conversion successful, bytes length: ${imageBytes.length}");

    // Save debug image
    try {
      final directory = await getApplicationDocumentsDirectory();
      final debugImagePath = p.join(directory.path, 'debug_gemma_input.jpg');
      final File debugFile = File(debugImagePath);
      await debugFile.writeAsBytes(imageBytes);
      print("DEBUG: Successfully saved processed image to: $debugImagePath");

      // if (mounted) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text("Debug image saved! Check console for path.")),
      //   );
      // }
    } catch (e) {
      print("DEBUG: Error saving debug image: $e");
    }

    const visionPrompt = """You are assisting a blind person. Describe what they might see in front of them right now, focusing on any obstacles, navigation aids, or important objects that would help them move safely. Be specific and detailed about what you actually see in this image.
    **Response Format:**
    - Be concise.
    - Limit your description to 2-4 sentences.
    - Provide only the most important information directly.
    """;
    print("DEBUG: Sending vision request to Gemma with image");

    await _generateStreamedResponse(visionPrompt, imageBytes: imageBytes);
  }

  Future<void> _processTextCommand(String command) async {
    print("DEBUG: Processing text-only command");

    final prompt = """You are a helpful assistant for a blind person. Please respond to: $command.
    **Response Format:**
    - Be concise.
    - Limit your answer to 2-3 sentences.
    - Directly answer the question without additional detail.
    """;
    await _generateStreamedResponse(prompt);
  }

  Future<void> _generateStreamedResponse(String prompt, {Uint8List? imageBytes}) async {
    if (!_gemmaService.isModelInitialized) {
      _setResponseAndSpeak("AI is not ready. Please ensure the model is properly installed.");
      return;
    }

    await _ttsService.stop();
    _assistantResponse.value = "AI is thinking...";

    try {
      print("DEBUG: Generating response - Has image: ${imageBytes != null}");

      final responseStream = _gemmaService.generateResponse(prompt, imageBytes: imageBytes);

      String fullResponse = "";
      StringBuffer speakBuffer = StringBuffer();
      RegExp sentenceEndings = RegExp(r'[.!?]\s+|\n+');

      await for (final token in responseStream) {
        if (token is TextResponse) {
          String currentToken = token.token;

          if (_isEndOfTurnToken(currentToken)) {
            print("DEBUG: End of turn detected immediately in token: '$currentToken'");

            String usefulContent = _extractContentBeforeEndMarker(currentToken);
            if (usefulContent.isNotEmpty) {
              fullResponse += usefulContent;
              speakBuffer.write(usefulContent);
              _assistantResponse.value = fullResponse;
              _scrollToBottom();
            }

            if (speakBuffer.isNotEmpty) {
              String finalText = speakBuffer.toString().trim();
              if (finalText.isNotEmpty) {
                print("DEBUG: Speaking final buffered text before ending: '${finalText.substring(0, finalText.length > 50 ? 50 : finalText.length)}...'");
                await _ttsService.speak(finalText);
              }
            }

            print("DEBUG: Stream ended due to end_of_turn detection");
            break;
          }

          String cleanedToken = _cleanResponseToken(currentToken);

          if (cleanedToken.isEmpty) {
            print("DEBUG: Token was completely filtered out: '$currentToken'");
            continue;
          }

          fullResponse += cleanedToken;
          speakBuffer.write(cleanedToken);

          _assistantResponse.value = fullResponse;
          _scrollToBottom();

          await _speakCompletedSentences(speakBuffer, sentenceEndings);

        } else if (token is ThinkingResponse) {
          print("DEBUG: Gemma thinking: ${token.content}");
        } else if (token is FunctionCallResponse) {
          print("DEBUG: Function call: ${token.name} with args: ${token.args}");
        } else {
          print("WARNING: Unexpected token type: ${token.runtimeType} - $token");
        }
      }

      if (speakBuffer.isNotEmpty) {
        String remainingText = speakBuffer.toString().trim();
        if (remainingText.isNotEmpty) {
          await _ttsService.speak(remainingText);
        }
      }

      if (fullResponse.trim().isEmpty) {
        _setResponseAndSpeak("I received an empty response. Please try again.");
        print("WARNING: Empty response from Gemma");
      } else {
        print("DEBUG: Final response completed. Length: ${fullResponse.length}");
      }

    } catch (e, stackTrace) {
      print("ERROR generating response: $e");
      print("Stack trace: $stackTrace");
      _setResponseAndSpeak("I'm sorry, I couldn't process that request.");
    }
  }

  String _extractContentBeforeEndMarker(String token) {
    final endMarkers = [
      '<end_of_turn>',
      '</end_of_turn>',
      '<|end_of_turn|>',
      '[end_of_turn]',
    ];

    String result = token;

    int earliestIndex = -1;
    for (String marker in endMarkers) {
      int index = token.toLowerCase().indexOf(marker.toLowerCase());
      if (index >= 0 && (earliestIndex == -1 || index < earliestIndex)) {
        earliestIndex = index;
      }
    }

    if (earliestIndex >= 0) {
      result = token.substring(0, earliestIndex);
      print("DEBUG: Extracted content before end marker: '$result'");
    }

    return _cleanResponseToken(result);
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
        print("DEBUG: End of turn token detected: '$endToken' in token starting with: '${token.substring(0, token.length > 30 ? 30 : token.length)}...'");
        return true;
      }
    }

    if (lowerToken.startsWith('<end_of_turn>') ||
        lowerToken.startsWith('<|end_of_turn|>') ||
        lowerToken.startsWith('[end_of_turn]')) {
      print("DEBUG: Token starts with end marker: '${token.substring(0, token.length > 30 ? 30 : token.length)}...'");
      return true;
    }

    return false;
  }

  Future<void> _speakCompletedSentences(StringBuffer speakBuffer, RegExp sentenceEndings) async {
    String bufferedText = speakBuffer.toString();
    int? lastMatchEnd;

    for (Match match in sentenceEndings.allMatches(bufferedText)) {
      lastMatchEnd = match.end;
    }

    if (lastMatchEnd != null) {
      String textToSpeak = bufferedText.substring(0, lastMatchEnd).trim();
      if (textToSpeak.isNotEmpty) {
        await _ttsService.speak(textToSpeak);

        speakBuffer.clear();
        String remainder = bufferedText.substring(lastMatchEnd);
        if (remainder.isNotEmpty) {
          speakBuffer.write(remainder);
        }
      }
    }
  }

  @override
  void dispose() {
    // Services' lifecycle is managed by Provider, so we don't dispose them here.
    // However, internal disposables managed BY the services themselves (like camera controller)
    // should still be disposed from within the service's own dispose method.
    // If your Provider creates a new instance each time and has a dispose method,
    // it will handle it.
    // For now, we only dispose the ValueNotifier and ScrollController.

    // No longer directly dispose services here:
    // _cameraService.dispose();
    // _gemmaService.chatInstance?.close(); // This should be handled by GemmaService's own dispose
    // _ttsService.dispose(); // This should be handled by TtsService's own dispose
    // _sttService.dispose(); // This should be handled by SttService's own dispose

    _assistantResponse.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blind Assist AI'),
        automaticallyImplyLeading: false,
      ),
      body: !_isFullyInitialized
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text("Setting up AI and Camera...",
                style: TextStyle(fontSize: 20)),
          ],
        ),
      )
          : Stack(
        children: [
          // Access cameraService via the late initialized field
          if (_cameraService.isInitialized &&
              _cameraService.controller != null)
            Positioned.fill(
              child: AspectRatio(
                aspectRatio: _cameraService.controller!.value.aspectRatio,
                child: CameraPreview(_cameraService.controller!),
              ),
            ),
          Positioned(
            bottom: 20, left: 20, right: 20,
            child: _buildControlPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    // You might also want to access isListening and lastWords from the _sttService instance
    // which is now a Provider-managed service.
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.25
            ),
            child: SingleChildScrollView(
              controller: _scrollController,
              child: ValueListenableBuilder<String>(
                valueListenable: _assistantResponse,
                builder: (context, response, child) {
                  return Text(
                    response,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Accessing _sttService.isListening via the instance
          ValueListenableBuilder<bool>(
            valueListenable: _sttService.isListening,
            builder: (context, isListening, child) {
              return FloatingActionButton(
                onPressed: () {
                  if (isListening) {
                    _sttService.stopListening();
                  } else {
                    _ttsService.stop();
                    _sttService.startListening(onFinalResult: _processCommand);
                  }
                },
                backgroundColor: isListening ? Colors.red : Colors.blue,
                child: Icon(isListening ? Icons.mic : Icons.mic_none),
              );
            },
          ),
          const SizedBox(height: 10),
          // Accessing _sttService.lastWords via the instance
          ValueListenableBuilder<String>(
            valueListenable: _sttService.lastWords,
            builder: (context, words, child) {
              return Text(
                _sttService.isListening.value && words.isNotEmpty // Accessing .value on ValueNotifier
                    ? words
                    : 'Tap to speak',
                style: const TextStyle(color: Colors.white70),
              );
            },
          ),
        ],
      ),
    );
  }
}