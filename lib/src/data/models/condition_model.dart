// lib/src/data/models/condition_model.dart

import 'package:flutter/material.dart';

enum ConditionType {
  blind,
  alzheimer,
  adhd,
  allergy,
  nightVision,
  autism,
}

class Condition {
  final ConditionType id;
  final String title;
  final String description;
  final IconData icon;

  Condition({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
  });
}

IconData _getIconData(String iconName) {
  switch (iconName) {
    case 'Eye':
      return Icons.visibility;
    case 'Brain':
      return Icons.psychology;
    case 'Activity':
      return Icons.fitness_center;
    case 'AlertTriangle':
      return Icons.warning_amber_outlined;
    case 'Moon':
      return Icons.mode_night;
    case 'Heart':
      return Icons.favorite;
    default:
      return Icons.help_outline;
  }
}

// Ensure this is lowercase 'conditions'
final List<Condition> conditions = [
  Condition(
    id: ConditionType.blind,
    title: 'Blind Assist',
    description: 'Real-time navigation and object recognition assistance',
    icon: _getIconData('Eye'),
  ),
  Condition(
    id: ConditionType.alzheimer,
    title: 'Alzheimer Helper',
    description: 'Memory aids and voice interaction for daily tasks',
    icon: _getIconData('Brain'),
  ),
  Condition(
    id: ConditionType.allergy,
    title: 'Allergy Checker',
    description: 'Identify potential allergens in food and environment',
    icon: _getIconData('AlertTriangle'),
  ),
  Condition(
    id: ConditionType.adhd,
    title: 'ADHD Helper',
    description: 'Task management, focus timer, and AI coaching',
    icon: _getIconData('Activity'),
  ),
  // Condition(
  //   id: ConditionType.nightVision,
  //   title: 'Night Vision',
  //   description: 'Enhanced visibility and alerts for low-vision driving',
  //   icon: _getIconData('Moon'),
  // ),
  Condition(
    id: ConditionType.autism,
    title: 'Autism Companion',
    description: 'Sensory-friendly tools and emotion tracking',
    icon: _getIconData('Heart'),
  ),
];