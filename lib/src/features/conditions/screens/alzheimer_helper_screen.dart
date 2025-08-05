// lib/src/features/conditions/screens/alzheimer_helper_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:gemma_final_app/src/config/theme.dart';
import 'package:gemma_final_app/src/shared_widgets/top_header_section.dart';
import 'package:gemma_final_app/src/shared_widgets/feature_card.dart';
import 'package:gemma_final_app/src/features/conditions/alzheimer_helper/services/alzheimer_gemma_service.dart';
import 'package:gemma_final_app/src/features/conditions/alzheimer_helper/screens/model_management_screen.dart';
import 'package:gemma_final_app/src/features/conditions/alzheimer_helper/screens/alzheimer_chat_screen.dart'; // NEW: Import the chat screen
import 'package:gemma_final_app/src/api/stt_service.dart';
import 'package:gemma_final_app/src/api/tts_service.dart';


class AlzheimerHelperScreen extends StatefulWidget {
  const AlzheimerHelperScreen({super.key});

  @override
  State<AlzheimerHelperScreen> createState() => _AlzheimerHelperScreenState();
}

class _AlzheimerHelperScreenState extends State<AlzheimerHelperScreen> {
  // Services
  AlzheimerGemmaService? _gemmaService;
  TtsService? _ttsService;
  SttService? _sttService;

  // State
  bool _isInitialized = false;
  String _initializationStatus = "Checking AI model...";

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _initializeServices();
    }
  }

  Future<void> _initializeServices() async {
    try {
      if (!mounted) return;
      setState(() {
        _initializationStatus = "Initializing services...";
      });

      _gemmaService = Provider.of<AlzheimerGemmaService>(context, listen: false);
      _ttsService = Provider.of<TtsService>(context, listen: false);
      _sttService = Provider.of<SttService>(context, listen: false);

      await _ttsService!.initialize();
      await _sttService!.initialize(onResult: (result) {});

      if (!mounted) return;
      setState(() {
        _initializationStatus = "Setting up AI model...";
      });

      final isModelInstalled = await _gemmaService!.isModelInstalled();
      if (!isModelInstalled) {
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AlzheimerModelManagementScreen(),
            ),
          ).then((_) {
            _checkModelStatusOnReturn();
          });
        }
        return;
      }

      await _gemmaService!.initializeForChat();

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _initializationStatus = "Ready!";
        });
      }

    } catch (e, stackTrace) {
      print("ERROR initializing Alzheimer services: $e");
      print("Stack trace: $stackTrace");
      if (mounted) {
        setState(() {
          _initializationStatus = "Setup failed. Please restart the app.";
        });
      }
    }
  }

  Future<void> _checkModelStatusOnReturn() async {
    if (mounted) {
      _isInitialized = false;
      _initializeServices();
    }
  }

  void _navigateToChat() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AlzheimerChatScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TopHeaderSection(
            titlePrimary: 'Alzheimer',
            titleSecondary: 'Helper',
            description: 'Memory aids and voice interaction',
            imageAssetPath: null,
            gradientStart: AppColors.alzheimerGradientStart,
            gradientEnd: AppColors.alzheimerGradientEnd,
          ),
          Expanded(
            child: _buildFeatureSelection(),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureSelection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FeatureCard(
            icon: Icons.event_note_outlined,
            title: 'Daily Reminders',
            description: 'Set reminders for medications, appointments, and daily tasks',
            accentColor: AppColors.alzheimerPrimary,
          ),
          FeatureCard(
            icon: Icons.calendar_today_outlined,
            title: 'Memory Journal',
            description: 'Record important memories and access them easily',
            accentColor: AppColors.alzheimerPrimary,
          ),
          FeatureCard(
            icon: Icons.people_outline,
            title: 'People Tracker',
            description: 'Keep track of important people in your life with photos and notes',
            accentColor: AppColors.alzheimerPrimary,
          ),
          FeatureCard(
            icon: Icons.psychology_outlined,
            title: 'Cognitive Games',
            description: 'Simple games to help maintain cognitive function',
            accentColor: AppColors.alzheimerPrimary,
          ),
          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              'Memory Assistant',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
          ),

          if (!_isInitialized)
            GestureDetector(
              onTap: () {
                if (mounted) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AlzheimerModelManagementScreen(),
                    ),
                  ).then((_) {
                    _checkModelStatusOnReturn();
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 12),
                    Text(
                      _initializationStatus,
                      style: TextStyle(fontSize: 15, color: AppColors.text),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            GestureDetector(
              onTap: _navigateToChat,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Hello! I'm your memory assistant. How can I help you today?",
                        style: TextStyle(fontSize: 15, color: AppColors.text),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.chat,
                      color: AppColors.alzheimerPrimary,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isInitialized ? _navigateToChat : null,
                  icon: const Icon(Icons.chat, color: Colors.white),
                  label: const Text('Start Chat', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.alzheimerPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}