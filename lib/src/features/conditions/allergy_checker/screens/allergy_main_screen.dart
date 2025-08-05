// lib/src/features/conditions/allergy_checker/screens/allergy_main_screen.dart

import 'package:flutter/material.dart';
import 'package:gemma_final_app/src/config/app_router.dart';
import 'package:gemma_final_app/src/features/conditions/allergy_checker/screens/allergy_camera_screen.dart';
import 'package:gemma_final_app/src/features/conditions/allergy_checker/services/allergy_gemma_service.dart';
import 'package:provider/provider.dart';

class AllergyMainScreen extends StatefulWidget {
  const AllergyMainScreen({super.key});

  @override
  State<AllergyMainScreen> createState() => _AllergyMainScreenState();
}

class _AllergyMainScreenState extends State<AllergyMainScreen> {
  // Hardcoded allergens for demonstration
  final List<String> userAllergens = ['peanut', 'dairy', 'gluten', 'soy'];
  String _statusMessage = "AI Model is not ready.";
  bool _isModelInitialized = false;

  @override
  void initState() {
    super.initState();
    _checkModelStatus();
  }

  Future<void> _checkModelStatus() async {
    final gemmaService = Provider.of<AllergyGemmaService>(context, listen: false);
    final isInitialized = gemmaService.isModelInitialized;

    setState(() {
      _isModelInitialized = isInitialized;
      _statusMessage = isInitialized ? "AI Model is ready to use." : "AI Model not initialized. Please go to setup.";
    });
  }

  void _navigateToCamera() {
    if (!_isModelInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please initialize the AI model first.')),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AllergyCameraScreen(userAllergens: userAllergens),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Allergy Checker'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: _isModelInitialized ? Colors.green.shade50 : Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _statusMessage,
                  style: TextStyle(
                    color: _isModelInitialized ? Colors.green.shade800 : Colors.red.shade800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your Allergens:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: userAllergens
                  .map((allergen) => Chip(
                label: Text(allergen),
                backgroundColor: Theme.of(context).chipTheme.backgroundColor,
              ))
                  .toList(),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _navigateToCamera,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Scan Ingredients'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}