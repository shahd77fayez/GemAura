import 'package:flutter/material.dart';
import 'package:gemma_final_app/src/config/theme.dart';

class HowToUseScreen extends StatelessWidget {
  const HowToUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('How to Use Blind Assist'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Getting Started:',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildStep(
              stepNumber: 1,
              title: 'Initialize the Model',
              description:
              'Before you begin, ensure the AI model is downloaded and ready. You will see an "Initializing..." message on the main screen until this is complete. Once the model is ready, the assistant will tell you: "I\'m ready to help you see."',
            ),
            _buildStep(
              stepNumber: 2,
              title: 'Start Talking',
              description:
              'Tap the microphone button to start a command. The button will turn red while it is listening. Speak clearly and concisely.',
            ),
            _buildStep(
              stepNumber: 3,
              title: 'Use Voice Commands',
              description:
              'You can ask questions like "What do you see?" or "Read the text in front of me." The assistant will process your command and respond verbally.',
            ),
            // Add more steps as needed
          ],
        ),
      ),
    );
  }

  Widget _buildStep({
    required int stepNumber,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: AppColors.blindPrimary,
            child: Text(
              '$stepNumber',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}