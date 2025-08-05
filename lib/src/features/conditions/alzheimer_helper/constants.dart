// lib/src/features/conditions/alzheimer_helper/constants.dart

// Gemma Model Configuration
import 'package:flutter/material.dart';

const String GEMMA_MODEL_FILENAME = 'gemma.task';
const String GEMMA_MODEL_URL = 'https://huggingface.co/google/gemma-3n-E4B-it-litert-preview/resolve/main/gemma-3n-E4B-it-int4.task';

// Chat Configuration
const int MAX_CONVERSATION_HISTORY = 10; // Keep last 10 messages for context
const int MAX_RESPONSE_TOKENS = 2048;
const double CHAT_TEMPERATURE = 0.7; // Slightly lower for more consistent responses

// Voice Settings
const Duration VOICE_PAUSE_DURATION = Duration(milliseconds: 800);
const Duration TYPING_ANIMATION_DURATION = Duration(milliseconds: 1500);

// UI Constants
const double CHAT_BUBBLE_RADIUS = 16.0;
const double AVATAR_RADIUS = 16.0;
const EdgeInsets MESSAGE_PADDING = EdgeInsets.all(12.0);
const EdgeInsets MESSAGE_MARGIN = EdgeInsets.symmetric(vertical: 4, horizontal: 8);

// Memory Assistant Prompts
const String MEMORY_ASSISTANT_SYSTEM_PROMPT = '''You are a compassionate memory assistant for someone who may have memory challenges. Your role is to:

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
- Focus on being helpful rather than diagnostic''';

// Quick Response Suggestions
const List<String> QUICK_RESPONSES = [
  "What did I do yesterday?",
  "Help me remember my daily routine",
  "What medications should I take?",
  "Tell me about my family members",
  "What appointments do I have?",
  "Help me remember important dates",
  "What should I do today?",
  "Can you remind me of something?",
];

// Memory Categories
enum MemoryCategory {
  medication,
  appointment,
  person,
  routine,
  important_date,
  task,
  memory,
  general,
}

// Extension for memory category display
extension MemoryCategoryExtension on MemoryCategory {
  String get displayName {
    switch (this) {
      case MemoryCategory.medication:
        return 'Medication';
      case MemoryCategory.appointment:
        return 'Appointment';
      case MemoryCategory.person:
        return 'Person';
      case MemoryCategory.routine:
        return 'Daily Routine';
      case MemoryCategory.important_date:
        return 'Important Date';
      case MemoryCategory.task:
        return 'Task';
      case MemoryCategory.memory:
        return 'Memory';
      case MemoryCategory.general:
        return 'General';
    }
  }

  String get icon {
    switch (this) {
      case MemoryCategory.medication:
        return '💊';
      case MemoryCategory.appointment:
        return '📅';
      case MemoryCategory.person:
        return '👤';
      case MemoryCategory.routine:
        return '🔄';
      case MemoryCategory.important_date:
        return '⭐';
      case MemoryCategory.task:
        return '✅';
      case MemoryCategory.memory:
        return '💭';
      case MemoryCategory.general:
        return '💬';
    }
  }
}