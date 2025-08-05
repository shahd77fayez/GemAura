// lib/services/stt_service.dart

import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SttService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final ValueNotifier<bool> isListening = ValueNotifier(false);
  final ValueNotifier<String> lastWords = ValueNotifier('');

  bool _isAvailable = false;

  Future<void> initialize({required Function onResult}) async {
    _isAvailable = await _speech.initialize(
      onError: (error) {
        print('STT Error: $error');
        isListening.value = false;
      },
      onStatus: (status) {
        isListening.value = _speech.isListening;
      },
    );
    print("STT initialized: $_isAvailable");
  }

  void startListening({required Function(String) onFinalResult}) {
    if (!_isAvailable || isListening.value) return;

    lastWords.value = '';
    _speech.listen(
      onResult: (result) {
        lastWords.value = result.recognizedWords;
        if (result.finalResult) {
          onFinalResult(result.recognizedWords);
        }
      },
      listenFor: const Duration(seconds: 17),
      pauseFor: const Duration(seconds: 7),
    );
  }

  void stopListening() {
    if (isListening.value) {
      _speech.stop();
    }
  }

  void dispose() {
    isListening.dispose();
    lastWords.dispose();
    _speech.cancel();
  }
}