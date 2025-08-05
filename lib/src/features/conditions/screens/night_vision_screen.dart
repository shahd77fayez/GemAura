// lib/src/features/conditions/screens/night_vision_screen.dart
import 'package:flutter/material.dart';
import 'package:gemma_final_app/src/config/theme.dart';
import 'package:gemma_final_app/src/shared_widgets/top_header_section.dart';

class NightVisionScreen extends StatelessWidget {
  const NightVisionScreen({super.key});

  // Helper for Night Vision Toggle Card
  Widget _buildToggleCard(BuildContext context, String title, String subtitle, bool value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.text)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 13, color: AppColors.subtext)),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: (bool newValue) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$title switched to $newValue')),
                );
                // Implement toggle logic here (requires StatefulWidget for state)
              },
              activeColor: AppColors.nightVisionPrimary,
            ),
          ],
        ),
      ),
    );
  }

  // Helper for Night Vision Action Button
  Widget _buildActionButton(BuildContext context, IconData icon, String label) {
    return ElevatedButton.icon(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label action')),
        );
      },
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.nightVisionPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TopHeaderSection( // Using the new TopHeaderSection widget
          titlePrimary: 'Night',
          titleSecondary: 'Vision',
          description: 'Enhanced visibility for low-vision driving',
          imageAssetPath: null,
          gradientStart: AppColors.nightVisionGradientStart,
          gradientEnd: AppColors.nightVisionGradientEnd,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Placeholder for video enhancement or map
                Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey[800], // Dark placeholder color
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_on_outlined, color: Colors.white.withOpacity(0.7), size: 40),
                        const SizedBox(height: 8),
                        Text('Map optimized for night driving', style: TextStyle(color: Colors.white.withOpacity(0.7))),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.location_on, color: Colors.white),
                            SizedBox(width: 16),
                            Icon(Icons.mic, color: Colors.white),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Display Settings', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.text)),
                const SizedBox(height: 16),
                _buildToggleCard(context, 'Dark Mode', 'Reduces eye strain in low light', true),
                _buildToggleCard(context, 'Voice Alerts', 'Spoken warnings for obstacles', false),
                _buildToggleCard(context, 'Auto Flashlight', 'Adjusts based on ambient light', true),
                const SizedBox(height: 24),
                Text('Quick Actions', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.text)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildActionButton(context, Icons.flashlight_on, 'Flashlight')),
                    const SizedBox(width: 16),
                    Expanded(child: _buildActionButton(context, Icons.volume_up_outlined, 'Voice Guide')),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }
}