// lib/src/features/conditions/widgets/condition_card.dart

import 'package:flutter/material.dart';
import 'package:gemma_final_app/src/data/models/condition_model.dart';
import 'package:gemma_final_app/src/config/theme.dart';

class ConditionCard extends StatelessWidget {
  final Condition condition;
  final VoidCallback? onTap; // Added onTap for navigation

  const ConditionCard({
    Key? key,
    required this.condition,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine background colors based on condition type (from AppColors)
    Color cardPrimaryColor;
    Color cardBackgroundColor;

    switch (condition.id) {
      case ConditionType.blind:
        cardPrimaryColor = AppColors.blindPrimary;
        cardBackgroundColor = AppColors.blindBackground;
        break;
      case ConditionType.alzheimer:
        cardPrimaryColor = AppColors.alzheimerPrimary;
        cardBackgroundColor = AppColors.alzheimerBackground;
        break;
      case ConditionType.adhd:
        cardPrimaryColor = AppColors.adhdPrimary;
        cardBackgroundColor = AppColors.adhdBackground;
        break;
      case ConditionType.allergy:
        cardPrimaryColor = AppColors.allergyPrimary;
        cardBackgroundColor = AppColors.allergyBackground;
        break;
      case ConditionType.nightVision:
        cardPrimaryColor = AppColors.nightVisionPrimary;
        cardBackgroundColor = AppColors.nightVisionBackground;
        break;
      case ConditionType.autism:
        cardPrimaryColor = AppColors.autismPrimary;
        cardBackgroundColor = AppColors.autismBackground;
        break;
    }

    return GestureDetector(
      onTap: onTap, // Handle tap
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: cardBackgroundColor, // Using specific background color
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardPrimaryColor.withOpacity(0.1), // Lighter tint of primary
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                condition.icon,
                size: 28,
                color: cardPrimaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    condition.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    condition.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.subtext,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.subtext.withOpacity(0.6),
            ),
            const SizedBox(width: 8),
            // The "Get Started >" text from the screenshot
            Text(
              'Get Started',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.primary, // Using primary for Get Started
              ),
            ),
          ],
        ),
      ),
    );
  }
}