// lib/src/features/home/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For SystemUiOverlayStyle
import 'package:provider/provider.dart'; // For state management

import 'package:gemma_final_app/src/config/theme.dart';
// IMPORTANT: This import brings in the 'conditions' list.
import 'package:gemma_final_app/src/data/models/condition_model.dart';
import 'package:gemma_final_app/src/data/providers/app_state_provider.dart';
import 'package:gemma_final_app/src/features/conditions/widgets/condition_card.dart'; // For ConditionCard widget
import 'package:gemma_final_app/src/config/app_router.dart'; // For navigation

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key}); // Using super.key

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final Size screenSize = MediaQuery.of(context).size;

    if (appState.isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                'Loading...',
                style: TextStyle(fontSize: 16, color: AppColors.text),
              ),
            ],
          ),
        ),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light, // For Android (dark icons on light status bar)
        statusBarBrightness: Brightness.dark, // For iOS (light icons on dark status bar)
        statusBarColor: Color(0xFF4A90E2), // Corresponds to the primary gradient start color
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: screenSize.height * 0.35, // Adjust based on content height
              floating: false,
              pinned: true,
              backgroundColor: Colors.transparent, // Transparent to show gradient
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF4A90E2), Color(0xFF357ABD), Color(0xFF2E6BA8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  padding: const EdgeInsets.only(top: 20, bottom: 40, left: 20, right: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Spacer(), // Pushes content to the bottom
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Welcome to',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withAlpha((255 * 0.9).round()), // Using withAlpha
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'GemAura',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Empowering lives through offline Gemma AI',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withAlpha((255 * 0.8).round()), // Using withAlpha
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha((255 * 0.1).round()), // Using withAlpha
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(Icons.favorite, '5', 'Conditions'),
                            _buildStatItem(Icons.verified_user, '24/7', 'Support'),
                            _buildStatItem(Icons.language, '140+', 'Languages'),
                          ],
                        ),
                      ),
                      const Spacer(flex: 2), // Pushes more content to the bottom
                    ],
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Transform.translate(
                          offset: const Offset(0, -20), // Adjust to lift content up
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha((255 * 0.1).round()), // Using withAlpha
                                  offset: const Offset(0, 4),
                                  blurRadius: 12,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              children: [
                                Text(
                                  'Choose Your Assistant',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.text,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Select the health assistance that best fits your needs',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.subtext,
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16), // Gap between header and cards
                        // Corrected map usage with .asMap().entries.map and removed unnecessary .toList()
                        // This uses the 'conditions' list (lowercase)
                        ...conditions.asMap().entries.map((entry) {
                          final int index = entry.key;
                          final Condition condition = entry.value;
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: 16, // Consistent gap between cards
                              top: index % 2 == 0 ? 0 : 10, // Conditional transform
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha((255 * 0.08).round()), // Using withAlpha
                                    offset: const Offset(0, 4),
                                    blurRadius: 12,
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: ConditionCard(
                                condition: condition,
                                onTap: () {
                                  // Use AppRouter for navigation
                                  String route;
                                  switch (condition.id) {
                                    case ConditionType.blind: route = AppRouter.blindAssistRoute; break;
                                    case ConditionType.alzheimer: route = AppRouter.alzheimerHelperRoute; break;
                                    case ConditionType.adhd: route = AppRouter.adhdHelperRoute; break;
                                    case ConditionType.allergy: route = AppRouter.allergyCheckerRoute; break;
                                    case ConditionType.nightVision: route = AppRouter.nightVisionRoute; break;
                                    case ConditionType.autism: route = AppRouter.autismCompanionRoute; break;
                                  }
                                  AppRouter.navigateTo(context, route);
                                },
                              ),
                            ),
                          );
                        }), // Removed .toList() as it's unnecessary in spreads
                        const SizedBox(height: 16),
                        Container(
                          margin: const EdgeInsets.only(top: 16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFF8F9FA), Color(0xFFE8F4FD)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha((255 * 0.05).round()), // Using withAlpha
                                offset: const Offset(0, 2),
                                blurRadius: 8,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              Text(
                                'Always Here for You',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.text,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Each GemAura tool is built to understand and help your unique needs anytime, anywhere.',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: AppColors.subtext,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String number, String label) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white.withAlpha((255 * 0.2).round()), // Using withAlpha
            ),
            child: Icon(icon, size: 20, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            number,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withAlpha((255 * 0.8).round()), // Using withAlpha
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}