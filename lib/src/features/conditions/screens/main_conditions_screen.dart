// lib/src/features/conditions/screens/main_conditions_screen.dart

import 'package:flutter/material.dart';
import 'package:gemma_final_app/src/config/theme.dart';

// Import individual condition screens
import 'package:gemma_final_app/src/features/conditions/screens/blind_assist_screen.dart';
import 'package:gemma_final_app/src/features/conditions/screens/allergy_checker_screen.dart';
import 'package:gemma_final_app/src/features/conditions/screens/alzheimer_helper_screen.dart';
import 'package:gemma_final_app/src/features/conditions/screens/adhd_helper_screen.dart';
import 'package:gemma_final_app/src/features/conditions/screens/night_vision_screen.dart';
import 'package:gemma_final_app/src/features/conditions/screens/autism_companion_screen.dart';


class ConditionsScreen extends StatelessWidget {
  final String conditionType;
  const ConditionsScreen({super.key, required this.conditionType});

  // Main builder to select the correct screen content
  Widget _buildConditionSpecificContent(String type, BuildContext context) {
    switch (type) {
      case 'blind':
        return const BlindAssistScreen(); // Use the new widget directly
      case 'alzheimer':
        return const AlzheimerHelperScreen(); // Use the new widget directly
      case 'adhd':
        return const ADHDHelperScreen(); // Use the new widget directly
      case 'allergy':
        return const AllergyCheckerScreen(); // Use the new widget directly
      case 'nightVision':
        return const NightVisionScreen(); // Use the new widget directly
      case 'autism':
        return const AutismCompanionScreen(); // Use the new widget directly
      default:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 80, color: Colors.grey),
              const SizedBox(height: 20),
              Text(
                'Content for "${conditionType.toUpperCase()}" is not yet defined.',
                style: TextStyle(fontSize: 20, color: AppColors.text),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // The back button is now handled within the TopHeaderSection of each screen
        // so we can remove the default leading here or make it an empty Container()
        leading: Container(),
      ),
      body: _buildConditionSpecificContent(conditionType, context),
    );
  }
}