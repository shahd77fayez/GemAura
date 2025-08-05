// lib/src/features/conditions/screens/adhd_helper_screen.dart
import 'package:flutter/material.dart';
import 'package:gemma_final_app/src/config/theme.dart';
import 'package:gemma_final_app/src/shared_widgets/top_header_section.dart';

class ADHDHelperScreen extends StatelessWidget {
  const ADHDHelperScreen({super.key});

  // Helper for ADHD Tabs
  Widget _buildADHDTab(BuildContext context, IconData icon, String label, bool isSelected) {
    return Expanded(
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$label tab selected')),
          );
          // Implement tab switching logic here
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.adhdPrimary.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: isSelected ? AppColors.adhdPrimary : AppColors.subtext),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppColors.adhdPrimary : AppColors.subtext,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper for ADHD Task Item
  Widget _buildADHDTaskItem(BuildContext context, String task, bool isCompleted, Color accentColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Row(
          children: [
            InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${isCompleted ? "Unmarked" : "Marked"} "$task" as complete')),
                );
                // Implement task completion toggle logic here (requires StatefulWidget for state)
              },
              child: Icon(
                isCompleted ? Icons.check_circle : Icons.radio_button_off,
                color: isCompleted ? AppColors.successGreen : AppColors.subtext,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                task,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.text,
                  decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                ),
              ),
            ),
            Container(
              width: 5,
              height: 30,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(2.5),
              ),
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
        TopHeaderSection( // Using the new TopHeaderSection widget
          titlePrimary: 'ADHD',
          titleSecondary: 'Helper',
          description: 'Task management, focus timer, and AI coaching',
          imageAssetPath: null,
          gradientStart: AppColors.adhdGradientStart,
          gradientEnd: AppColors.adhdGradientEnd,
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
                      _buildADHDTab(context, Icons.checklist_outlined, 'Tasks', true), // Selected
                      _buildADHDTab(context, Icons.timer_outlined, 'Focus', false),
                      _buildADHDTab(context, Icons.chat_bubble_outline, 'AI Coach', false),
                      _buildADHDTab(context, Icons.settings_outlined, 'Settings', false),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // --- Today's Tasks Section ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Today's Tasks",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Add Task pressed')),
                        );
                      },
                      icon: const Icon(Icons.add, size: 20, color: Colors.white),
                      label: const Text('Add Task', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.adhdPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildADHDTaskItem(context, 'Take medication', false, AppColors.alertRed),
                _buildADHDTaskItem(context, 'Doctor appointment', true, AppColors.warningYellow),
                _buildADHDTaskItem(context, 'Drink water', false, AppColors.successGreen),
                _buildADHDTaskItem(context, 'Exercise for 15 minutes', false, AppColors.warningYellow),
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