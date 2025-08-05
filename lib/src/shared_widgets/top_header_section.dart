// lib/src/common_widgets/top_header_section.dart
import 'package:flutter/material.dart';
import 'package:gemma_final_app/src/config/theme.dart'; // Make sure this path is correct

class TopHeaderSection extends StatelessWidget {
  final String titlePrimary;
  final String titleSecondary;
  final String description;
  final Color gradientStart;
  final Color gradientEnd;
  final String? imageAssetPath;

  const TopHeaderSection({
    super.key,
    required this.titlePrimary,
    required this.titleSecondary,
    required this.description,
    required this.gradientStart,
    required this.gradientEnd,
    this.imageAssetPath,
  });

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      height: 232 + statusBarHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [gradientStart, gradientEnd],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: gradientEnd.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          if (imageAssetPath != null && imageAssetPath!.isNotEmpty) // Add '!'
            Positioned.fill(
              child: Opacity(
                opacity: 0.8,
                child: Image.asset(
                  imageAssetPath!,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.broken_image, size: 50, color: Colors.white70),
                          const SizedBox(height: 10),
                          Text(
                            'Image not found: ${imageAssetPath!.split('/').last}',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        titlePrimary,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        titleSecondary,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.normal,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.start,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}