// lib/src/features/conditions/alzheimer_helper/screens/alzheimer_chat_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_gemma/core/message.dart';
import 'package:flutter_gemma/core/model_response.dart';
import 'package:provider/provider.dart';

import 'package:gemma_final_app/src/api/stt_service.dart';
import 'package:gemma_final_app/src/api/tts_service.dart';
import 'package:gemma_final_app/src/config/theme.dart';
import 'package:gemma_final_app/src/features/conditions/alzheimer_helper/services/alzheimer_gemma_service.dart';
import 'package:gemma_final_app/src/features/conditions/alzheimer_helper/widgets/chat_message_widget.dart';


class AlzheimerChatScreen extends StatefulWidget {
  const AlzheimerChatScreen({super.key});

  @override
  State<AlzheimerChatScreen> createState() => _AlzheimerChatScreenState();
}

class _AlzheimerChatScreenState extends State<AlzheimerChatScreen> {
  late AlzheimerGemmaService _gemmaService;
  late TtsService _ttsService;
  late SttService _sttService;

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();

  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _messages.add(ChatMessage(
      text: "Hello! I'm your memory assistant. How can I help you today?",
      isUser: false,
    ));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ttsService.speak("Hello! I'm your memory assistant. How can I help you today?");
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _gemmaService = Provider.of<AlzheimerGemmaService>(context, listen: false);
    _ttsService = Provider.of<TtsService>(context, listen: false);
    _sttService = Provider.of<SttService>(context, listen: false);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(text: text.trim(), isUser: true);

    setState(() {
      _messages.add(userMessage);
      _isTyping = true;
    });

    _messageController.clear();
    _scrollToBottom();

    await _ttsService.stop();

    try {
      final responseStream = _gemmaService.generateMemoryResponse(text.trim());
      String fullResponse = "";
      String currentResponse = "";

      await for (final token in responseStream) {
        if (token is TextResponse) {
          String cleanedToken = _cleanResponseToken(token.token);

          if (_isEndOfTurnToken(token.token)) {
            String usefulContent = _extractContentBeforeEndMarker(token.token);
            if (usefulContent.isNotEmpty) {
              fullResponse += usefulContent;
              currentResponse += usefulContent;
            }
            break;
          }

          if (cleanedToken.isNotEmpty) {
            fullResponse += cleanedToken;
            currentResponse += cleanedToken;

            if (mounted) {
              setState(() {
                if (_messages.isNotEmpty && !_messages.last.isUser) {
                  _messages.last = ChatMessage(
                    text: currentResponse,
                    isUser: false,
                  );
                } else {
                  _messages.add(ChatMessage(
                    text: currentResponse,
                    isUser: false,
                  ));
                }
              });
              _scrollToBottom();
            }
          }
        }
      }

      if (mounted) {
        setState(() {
          _isTyping = false;
          if (_messages.isNotEmpty && !_messages.last.isUser) {
            _messages.last = ChatMessage(
              text: fullResponse.trim(),
              isUser: false,
            );
          }
        });
      }

      if (fullResponse.trim().isNotEmpty) {
        await _ttsService.speak(fullResponse.trim());
      }

    } catch (e, stackTrace) {
      print("ERROR generating response: $e");
      print("Stack trace: $stackTrace");

      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(ChatMessage(
            text: "I'm sorry, I encountered an error. Please try again.",
            isUser: false,
          ));
        });
        _scrollToBottom();
      }
    }
  }

  void _handleVoiceInput() async {
    if (_sttService.isListening.value) {
      _sttService.stopListening();
    } else {
      _ttsService.stop();
      _sttService.startListening(
        onFinalResult: (result) {
          if (result.trim().isNotEmpty) {
            _sendMessage(result);
          }
        },
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _cleanResponseToken(String token) {
    return token
        .replaceAll('<end_of_turn>', '')
        .replaceAll('</end_of_turn>', '')
        .replaceAll('<|end_of_turn|>', '')
        .replaceAll('[end_of_turn]', '')
        .replaceAll('<start_of_turn>', '')
        .replaceAll('<|start_of_turn|>', '')
        .replaceAll(RegExp(r'<[^>]*>'), '');
  }

  bool _isEndOfTurnToken(String token) {
    final endTokens = [
      '<end_of_turn>',
      '</end_of_turn>',
      '<|end_of_turn|>',
      '[end_of_turn]',
    ];

    String lowerToken = token.toLowerCase();
    return endTokens.any((endToken) => lowerToken.contains(endToken.toLowerCase()));
  }

  String _extractContentBeforeEndMarker(String token) {
    final endMarkers = ['<end_of_turn>', '</end_of_turn>', '<|end_of_turn|>', '[end_of_turn]'];

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
    }

    return _cleanResponseToken(result);
  }

  void _showClearConversationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Conversation'),
        content: const Text('Are you sure you want to clear the conversation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _messages.clear();
                _messages.add(ChatMessage(
                  text: "Hello! I'm your memory assistant. How can I help you today?",
                  isUser: false,
                ));
              });
              _ttsService.speak("Hello! I'm your memory assistant. How can I help you today?");
              Navigator.of(context).pop();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get the height of the keyboard
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60.0,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.alzheimerPrimary,
                child: const Icon(
                  Icons.psychology,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Memory Assistant',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    Text(
                      'Always here to help',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.subtext,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            onPressed: _showClearConversationDialog,
            icon: const Icon(Icons.refresh),
            tooltip: 'Clear conversation',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: keyboardHeight),
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length && _isTyping) {
                      return const TypingIndicator();
                    }
                    return ChatMessageWidget(message: _messages[index]);
                  },
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ValueListenableBuilder<bool>(
                    valueListenable: _sttService.isListening,
                    builder: (context, isListening, child) {
                      if (isListening) {
                        return ValueListenableBuilder<String>(
                          valueListenable: _sttService.lastWords,
                          builder: (context, words, child) {
                            if (words.isNotEmpty) {
                              return Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(8),
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.alzheimerPrimary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.alzheimerPrimary.withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  'Listening: $words',
                                  style: TextStyle(
                                    color: AppColors.alzheimerPrimary,
                                    fontSize: 14,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          focusNode: _messageFocusNode,
                          decoration: InputDecoration(
                            hintText: 'Type your message or press mic to speak...',
                            hintStyle: TextStyle(
                              color: AppColors.subtext.withOpacity(0.7),
                            ),
                            filled: true,
                            fillColor: Colors.grey.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 20,
                            ),
                          ),
                          style: TextStyle(color: AppColors.text),
                          maxLines: null,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (text) {
                            if (text.trim().isNotEmpty) {
                              _sendMessage(text);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      ValueListenableBuilder<bool>(
                        valueListenable: _sttService.isListening,
                        builder: (context, isListening, child) {
                          return FloatingActionButton(
                            onPressed: _handleVoiceInput,
                            backgroundColor: isListening
                                ? Colors.red
                                : AppColors.alzheimerPrimary,
                            mini: true,
                            child: Icon(
                              isListening ? Icons.mic : Icons.mic_none,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      FloatingActionButton(
                        onPressed: () {
                          final text = _messageController.text;
                          if (text.trim().isNotEmpty) {
                            _sendMessage(text);
                          }
                        },
                        backgroundColor: AppColors.alzheimerPrimary,
                        mini: true,
                        child: const Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}