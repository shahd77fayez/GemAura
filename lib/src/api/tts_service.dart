// lib/services/tts_service.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  final ValueNotifier<bool> isSpeaking = ValueNotifier(false);

  Future<void> initialize() async {
    _flutterTts.setStartHandler(() => isSpeaking.value = true);
    _flutterTts.setCompletionHandler(() => isSpeaking.value = false);
    _flutterTts.setErrorHandler((msg) {
      print("TTS Error: $msg");
      isSpeaking.value = false;
    });

    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);

    // Set queue mode to flush (don't queue multiple speeches)
    await _flutterTts.setQueueMode(0); // 0 = QUEUE_FLUSH, 1 = QUEUE_ADD

    print("TTS initialized.");
  }

  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;

    // Safety check: Don't speak text containing end markers
    String lowerText = text.toLowerCase();
    if (lowerText.contains('<end_of_turn>') ||
        lowerText.contains('end_of_turn') ||
        lowerText.contains('<|end_of_turn|>') ||
        lowerText.contains('[end_of_turn]')) {
      print("WARNING: TTS blocked text containing end markers: '${text.substring(0, text.length > 50 ? 50 : text.length)}...'");
      return;
    }

    // Always stop current speech before starting new one
    if (isSpeaking.value) {
      await _flutterTts.stop();
    }

    print("DEBUG: TTS speaking: '${text.substring(0, text.length > 50 ? 50 : text.length)}...'");
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
    isSpeaking.value = false;
  }

  void dispose() {
    isSpeaking.dispose();
    _flutterTts.stop();
  }
}