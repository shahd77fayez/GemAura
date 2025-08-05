// lib/src/features/conditions/screens/autism_companion_screen.dart
import 'package:flutter/material.dart';
import 'package:gemma_final_app/src/config/theme.dart';
import 'package:gemma_final_app/src/shared_widgets/top_header_section.dart';

class AutismCompanionScreen extends StatelessWidget {
  const AutismCompanionScreen({super.key});

  // Helper for Autism Tabs
  Widget _buildAutismTab(BuildContext context, String label, bool isSelected) {
    return Expanded(
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$label tab selected')),
          );
          // Implement tab switching logic here (requires StatefulWidget for state)
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.autismPrimary.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.autismPrimary : AppColors.subtext,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper for Autism Emotion Button
  Widget _buildEmotionButton(BuildContext context, IconData icon, String label) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Feeling: $label')),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: AppColors.autismPrimary),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(fontSize: 14, color: AppColors.text),
            ),
          ],
        ),
      ),
    );
  }

  // We are creating a new widget here to hold the main content
  Widget _buildMainContent(BuildContext context) {
    return Column(
      children: [
        TopHeaderSection(
          titlePrimary: 'Autism',
          titleSecondary: 'Companion',
          description: 'Sensory-friendly tools and emotion tracking',
          imageAssetPath: null,
          gradientStart: AppColors.autismGradientStart,
          gradientEnd: AppColors.autismGradientEnd,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Tab Bar ---
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildAutismTab(context, 'Emotions', true), // Selected
                      _buildAutismTab(context, 'Routines', false),
                      _buildAutismTab(context, 'Communication', false),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // --- How are you feeling? Section ---
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    'How are you feeling?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                ),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    _buildEmotionButton(context, Icons.sentiment_satisfied_outlined, 'Happy'),
                    _buildEmotionButton(context, Icons.sentiment_dissatisfied_outlined, 'Sad'),
                    _buildEmotionButton(context, Icons.sentiment_neutral_outlined, 'Calm'),
                    _buildEmotionButton(context, Icons.warning_outlined, 'Anxious'),
                    _buildEmotionButton(context, Icons.flash_on_outlined, 'Excited'),
                    _buildEmotionButton(context, Icons.heart_broken_outlined, 'Frustrated'),
                  ],
                ),
                const SizedBox(height: 24),
                // --- Recent Emotions Section ---
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text(
                    'Recent Emotions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: Text(
                    'No emotions logged yet. Use the tracker above to record how you\'re feeling.',
                    style: TextStyle(fontSize: 15, color: AppColors.subtext),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. The main content of the screen (bottom layer)
        _buildMainContent(context),

        // 2. The dimming overlay and "Coming Soon" message (top layers)
        // We use a Positioned.fill to make the overlay cover the entire screen.
        Positioned.fill(
          child: IgnorePointer( // This prevents the user from interacting with the dimmed content
            child: Container(
              color: AppColors.background.withOpacity(0.8), // Adjust opacity for desired dimming
            ),
          ),
        ),

        // 3. The "Coming Soon" message centered on top
        Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card.withOpacity(0.3), // Changed opacity here
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Text(
              'This feature will be coming soon',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black, // Changed color here
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}