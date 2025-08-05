// S:\Projects\gemma_final_app\lib\main.dart

import 'package:flutter/material.dart';
import 'package:gemma_final_app/src/features/conditions/allergy_checker/services/allergy_gemma_service.dart';
import 'package:provider/provider.dart';

// Your existing imports
import 'package:gemma_final_app/src/data/providers/app_state_provider.dart';
import 'package:gemma_final_app/src/features/home/screens/home_screen.dart'; // Though not directly used in MyApp build, good to keep if homescreen is your initial route
import 'package:gemma_final_app/src/config/theme.dart';
import 'package:gemma_final_app/src/config/app_router.dart';

// EXISTING IMPORTS for services
import 'package:gemma_final_app/src/features/conditions/blind_assist/services/gemma_service.dart';
import 'package:gemma_final_app/src/features/conditions/blind_assist/services/camera_service.dart';
import 'package:gemma_final_app/src/api/stt_service.dart'; // Assuming you put STT here
import 'package:gemma_final_app/src/api/tts_service.dart'; // Assuming you put TTS here

// NEW IMPORT for Alzheimer service
import 'package:gemma_final_app/src/features/conditions/alzheimer_helper/services/alzheimer_gemma_service.dart';

void main() {
  // Ensure Flutter engine is initialized before using plugins
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
        // Add other existing providers here if needed (e.g., conditions_provider)

        // EXISTING: Add providers for the services used in Blind Assist
        Provider<GemmaService>(create: (_) => GemmaService()),
        Provider<CameraService>(create: (_) => CameraService()),
        Provider<SttService>(create: (_) => SttService()),
        Provider<TtsService>(create: (_) => TtsService()),
        // NEW: Add provider for Alzheimer Gemma Service
        Provider<AlzheimerGemmaService>(create: (_) => AlzheimerGemmaService()),
        Provider(create: (_) => AllergyGemmaService()), // Add the new service here
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GemAura',
      theme: ThemeData(
        primaryColor: AppColors.primary,
        hintColor: AppColors.accent,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary, // Default app bar color
          foregroundColor: Colors.white, // Default app bar text/icon color
          elevation: 0,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: AppColors.text),
          displayMedium: TextStyle(color: AppColors.text),
          displaySmall: TextStyle(color: AppColors.text),
          headlineLarge: TextStyle(color: AppColors.text),
          headlineMedium: TextStyle(color: AppColors.text),
          headlineSmall: TextStyle(color: AppColors.text),
          titleLarge: TextStyle(color: AppColors.text),
          titleMedium: TextStyle(color: AppColors.text),
          titleSmall: TextStyle(color: AppColors.text),
          bodyLarge: TextStyle(color: AppColors.text),
          bodyMedium: TextStyle(color: AppColors.text),
          bodySmall: TextStyle(color: AppColors.text),
          labelLarge: TextStyle(color: AppColors.text),
          labelMedium: TextStyle(color: AppColors.text),
          labelSmall: TextStyle(color: AppColors.text),
        ),
        // Add other theme properties as needed
      ),
      // Use the router for named routes
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: AppRouter.homeRoute, // Set initial route
    );
  }
}