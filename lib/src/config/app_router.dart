// lib/src/config/app_router.dart

import 'package:flutter/material.dart';
import 'package:gemma_final_app/src/features/conditions/blind_assist/screens/blind_assist_overview_screen.dart';
import 'package:gemma_final_app/src/features/conditions/blind_assist/screens/how_to_use_screen.dart';
import 'package:gemma_final_app/src/features/home/screens/home_screen.dart';
import 'package:gemma_final_app/src/features/conditions/screens/main_conditions_screen.dart';
import 'package:gemma_final_app/src/features/conditions/blind_assist/screens/assist_screen.dart';
import 'package:gemma_final_app/src/features/conditions/blind_assist/screens/model_management_screen.dart'; // <--- NEW IMPORT

class AppRouter {
  static const String homeRoute = '/';
  static const String blindAssistRoute = '/blind';
  static const String blindAssistFunctionalityRoute = '/blind/functionality';
  static const String modelManagementRoute = '/model_management'; // <--- NEW ROUTE
  static const String alzheimerHelperRoute = '/alzheimer';
  static const String adhdHelperRoute = '/adhd';
  static const String allergyCheckerRoute = '/allergy';
  static const String nightVisionRoute = '/nightVision';
  static const String autismCompanionRoute = '/autism';
  static const String blindAssistOverviewRoute = '/blind-assist-overview';
  static const String howToUseRoute = '/how-to-use';
  // Add other routes as needed

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case homeRoute:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case blindAssistRoute:
        return MaterialPageRoute(builder: (_) => const ConditionsScreen(conditionType: 'blind'));
      case blindAssistFunctionalityRoute:
        return MaterialPageRoute(builder: (_) => const AssistScreen());
      case modelManagementRoute: // <--- NEW CASE
        return MaterialPageRoute(builder: (_) => const ModelManagementScreen());
      case alzheimerHelperRoute:
        return MaterialPageRoute(builder: (_) => const ConditionsScreen(conditionType: 'alzheimer'));
      case adhdHelperRoute:
        return MaterialPageRoute(builder: (_) => const ConditionsScreen(conditionType: 'adhd'));
      case allergyCheckerRoute:
        return MaterialPageRoute(builder: (_) => const ConditionsScreen(conditionType: 'allergy'));
      case nightVisionRoute:
        return MaterialPageRoute(builder: (_) => const ConditionsScreen(conditionType: 'nightVision'));
      case autismCompanionRoute:
        return MaterialPageRoute(builder: (_) => const ConditionsScreen(conditionType: 'autism'));
      case blindAssistOverviewRoute:
        return MaterialPageRoute(
          builder: (_) => const BlindAssistOverviewScreen(),
        );

      case howToUseRoute:
        return MaterialPageRoute(
          builder: (_) => const HowToUseScreen(),
        );
      default:
        return MaterialPageRoute(builder: (_) => const Text('Error: Unknown route'));
    }
  }

  static void navigateTo(BuildContext context, String routeName) {
    Navigator.pushNamed(context, routeName);
  }
}