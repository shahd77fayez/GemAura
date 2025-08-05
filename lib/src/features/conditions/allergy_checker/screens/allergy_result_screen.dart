// lib/src/features/conditions/allergy_checker/screens/allergy_result_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gemma_final_app/src/config/theme.dart';

class AllergyResultScreen extends StatelessWidget {
  final String imagePath;
  final Map<String, dynamic> analysisResult;
  final List<String> userAllergens;

  const AllergyResultScreen({
    super.key,
    required this.imagePath,
    required this.analysisResult,
    required this.userAllergens,
  });

  @override
  Widget build(BuildContext context) {
    final String status = analysisResult['status'] ?? 'Error';
    final String title = analysisResult['title'] ?? 'Product';
    final String message = analysisResult['message'] ?? 'Unable to determine ingredients.';
    final List<String> detectedAllergens = List<String>.from(analysisResult['detected_allergens'] ?? []);

    final bool isAlert = status == 'Alert';

    // Corrected to use `successGreen` from your AppColors
    final Color statusColor = isAlert ? AppColors.alertRed : AppColors.successGreen;
    final String statusText = isAlert ? 'Allergens Detected' : 'Allergen-Free';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Result'),
        backgroundColor: isAlert ? AppColors.alertRed : AppColors.successGreen,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Display the captured image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(imagePath),
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),

              // Status Card
              Card(
                color: statusColor.withOpacity(0.2),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: statusColor, width: 2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Product: $title',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        message,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                'Detected Allergens:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // List of detected allergens
              if (detectedAllergens.isNotEmpty)
                ...detectedAllergens.map((allergen) =>
                    ListTile(
                      leading: const Icon(Icons.warning, color: AppColors.alertRed),
                      title: Text(allergen),
                    )
                ).toList()
              else
                ListTile(
                  // Corrected to use `successGreen`
                  leading: const Icon(Icons.check_circle, color: AppColors.successGreen),
                  title: const Text('None detected from your list.'),
                ),
              const SizedBox(height: 24),

              // Back button
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.allergyPrimary,
                  // This ensures the text color is always white for good contrast
                  foregroundColor: AppColors.card,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Scan Another Product',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}