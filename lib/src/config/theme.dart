// lib/src/config/theme.dart
import 'package:flutter/material.dart';

class AppColors {
  // Base Colors
  static const Color primary = Color(0xFF6200EE); // Deep Purple
  static const Color secondary = Color(0xFF03DAC6); // Teal
  static const Color background = Color(0xFFF0F2F5); // Light Grey/Off-white background
  static const Color card = Color(0xFFFFFFFF); // White for cards and elevated surfaces
  static const Color text = Color(0xFF212121); // Dark grey for primary text
  static const Color subtext = Color(0xFF757575); // Medium grey for secondary text

  // Condition Specific Colors

  // Blind Assist
  static const Color blindPrimary = Color(0xFF2196F3); // Blue
  static const Color blindGradientStart = Color(0xFF2196F3); // Lighter Blue
  static const Color blindGradientEnd = Color(0xFF1976D2);   // Darker Blue
  static const Color blindBackground = Color(0xFFE3F2FD); // Very light blue for screens

  // Allergy Checker (UPDATED COLORS FOR GREEN)
  static const Color allergyPrimary = Color(0xFF4CAF50);       // Green
  static const Color allergyGradientStart = Color(0xFF81C784); // Light Green
  static const Color allergyGradientEnd = Color(0xFF388E3C);   // Darker Green
  static const Color allergyBackground = Color(0xFFE8F5E9); // Very light green for screens

  // Alzheimer Helper
  static const Color alzheimerPrimary = Color(0xFF9C27B0); // Purple
  static const Color alzheimerGradientStart = Color(0xFFBA68C8); // Light Purple
  static const Color alzheimerGradientEnd = Color(0xFF8E24AA);   // Darker Purple
  static const Color alzheimerBackground = Color(0xFFF3E5F5); // Very light purple

  // ADHD Helper
  static const Color adhdPrimary = Color(0xFFFF9800); // Orange
  static const Color adhdGradientStart = Color(0xFFFFB74D); // Light Orange
  static const Color adhdGradientEnd = Color(0xFFFB8C00);   // Darker Orange
  static const Color adhdBackground = Color(0xFFFFF3E0); // Very light orange

  // Night Vision
  static const Color nightVisionPrimary = Color(0xFF673AB7); // Deep Purple
  static const Color nightVisionGradientStart = Color(0xFF9575CD); // Lighter Deep Purple
  static const Color nightVisionGradientEnd = Color(0xFF5E35B1);   // Darker Deep Purple
  static const Color nightVisionBackground = Color(0xFFEDE7F6); // Very light deep purple

  // Autism Companion
  static const Color autismPrimary = Color(0xFF00BCD4); // Cyan
  static const Color autismGradientStart = Color(0xFF4DD0E1); // Lighter Cyan
  static const Color autismGradientEnd = Color(0xFF00ACC1);   // Darker Cyan
  static const Color autismBackground = Color(0xFFE0F7FA); // Very light cyan

  // Alert/Status Colors
  static const Color alertRed = Color(0xFFD32F2F);   // A strong red for alerts/warnings
  static const Color warningYellow = Color(0xFFFBC02D); // A distinct yellow for warnings
  static const Color successGreen = Color(0xFF388E3C); // A clear green for success/safe
  static const Color accent = Color(0xFF03DAC6); // Or choose your desired accent color
}