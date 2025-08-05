// S:\Projects\gemma_final_app\lib\src\shared_widgets\feature_card.dart
import 'package:flutter/material.dart';
import 'package:gemma_final_app/src/config/theme.dart'; // Make sure this path is correct

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final Color accentColor;
  final VoidCallback? onTap; // NEW: Add an optional onTap callback

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    required this.accentColor,
    this.onTap, // NEW: Include it in the constructor
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
      ),
      child: InkWell(
        // Use the provided onTap callback, or fall back to a default if not provided
        onTap: onTap ?? () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tapped on $title')),
          );
        },
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accentColor, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                    if (description != null && description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        description!,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.subtext,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}