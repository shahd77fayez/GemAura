// lib/src/features/conditions/screens/allergy_checker_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:gemma_final_app/src/config/theme.dart';
import 'package:gemma_final_app/src/shared_widgets/top_header_section.dart';
import 'package:gemma_final_app/src/features/conditions/allergy_checker/services/allergy_gemma_service.dart';
import 'package:gemma_final_app/src/features/conditions/allergy_checker/screens/allergy_model_management_screen.dart';
import 'package:gemma_final_app/src/features/conditions/allergy_checker/screens/allergy_camera_screen.dart';

// A simple model to represent a scan result
class ScanResult {
  final String title;
  final String subtitle;
  final String status; // "Alert", "Safe", or "Pending"
  final String imagePath;
  final Color statusColor;
  final DateTime timestamp;
  final List<String> detectedAllergens;

  ScanResult({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.imagePath,
    required this.statusColor,
    required this.timestamp,
    required this.detectedAllergens,
  });
}

class AllergyCheckerScreen extends StatefulWidget {
  const AllergyCheckerScreen({super.key});

  @override
  State<AllergyCheckerScreen> createState() => _AllergyCheckerScreenState();
}

class _AllergyCheckerScreenState extends State<AllergyCheckerScreen> {
  late AllergyGemmaService _gemmaService;
  List<ScanResult> _recentScans = [];
  bool _isProcessingScan = false;

  // Hardcoded for now, but in a real app, this would be user-defined and
  // managed by a state provider.
  final List<String> _userAllergens = ['Peanuts', 'Dairy', 'Gluten', 'Shellfish', 'Eggs', 'Tree Nuts'];

  @override
  void initState() {
    super.initState();
    _loadDemoData(); // Add some demo data
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _gemmaService = Provider.of<AllergyGemmaService>(context, listen: false);
  }

  void _loadDemoData() {
    // Add some demo scan results
    _recentScans = [
      ScanResult(
        title: 'Chocolate Bar',
        subtitle: 'Contains dairy and may contain traces of nuts',
        status: 'Alert',
        imagePath: 'assets/images/chocolate_bar.png',
        statusColor: AppColors.alertRed,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        detectedAllergens: ['Dairy', 'Tree Nuts'],
      ),
      ScanResult(
        title: 'Apple',
        subtitle: 'No allergens detected',
        status: 'Safe',
        imagePath: 'assets/images/apple.png',
        statusColor: AppColors.successGreen,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        detectedAllergens: [],
      ),
    ];
  }

  Future<bool> _checkPermissions() async {
    final status = await Permission.camera.status;

    if (status.isDenied) {
      final result = await Permission.camera.request();
      return result.isGranted;
    }

    return status.isGranted;
  }

  Future<void> _handleScanFood() async {
    // Check camera permissions first
    final hasPermission = await _checkPermissions();
    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Camera permission is required to scan food products'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Check if the model is initialized
    if (!_gemmaService.isModelInitialized) {
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const AllergyModelManagementScreen(isAutoNavigate: false),
        ),
      );

      // Re-check after returning from the setup screen
      if (!_gemmaService.isModelInitialized) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gemma model is not ready. Please install it first.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    if (_isProcessingScan) return;

    try {
      // Navigate to camera screen
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AllergyCameraScreen(
            userAllergens: _userAllergens,
          ),
        ),
      );

      if (result != null && result is Map<String, dynamic>) {
        final scanResult = result['result'] as Map<String, dynamic>;
        final imagePath = result['imagePath'] as String;

        // Create new scan result
        final newScan = ScanResult(
          title: scanResult['title'] ?? 'Unknown Product',
          subtitle: scanResult['message'] ?? 'Could not determine.',
          status: scanResult['status'] ?? 'Error',
          imagePath: imagePath,
          statusColor: _getStatusColor(scanResult['status'] ?? 'Error'),
          timestamp: DateTime.now(),
          detectedAllergens: List<String>.from(scanResult['detected_allergens'] ?? []),
        );

        setState(() {
          _recentScans.insert(0, newScan); // Add to the top of the list
        });

        // Show result notification
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  newScan.status == 'Alert' ? Icons.warning : Icons.check_circle,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${newScan.status}: ${newScan.title}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            backgroundColor: newScan.statusColor,
            duration: const Duration(seconds: 4),
          ),
        );
      }

    } catch (e) {
      print("Error during scan: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to scan: ${e.toString()}'),
          backgroundColor: AppColors.alertRed,
        ),
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'alert':
        return AppColors.alertRed;
      case 'safe':
        return AppColors.successGreen;
      default:
        return Colors.grey;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  // Helper for the "Scan Food or Product" button
  Widget _buildScanFoodButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0),
      child: ElevatedButton.icon(
        onPressed: _isProcessingScan ? null : _handleScanFood,
        icon: _isProcessingScan
            ? const SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
        )
            : const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 24),
        label: Text(
          _isProcessingScan ? 'Scanning...' : 'Scan Food or Product',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.allergyPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 5,
          minimumSize: const Size(double.infinity, 60),
        ),
      ),
    );
  }

  // Helper for the search bar
  Widget _buildSearchBar(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search for allergens...',
        hintStyle: TextStyle(color: AppColors.subtext.withOpacity(0.7)),
        prefixIcon: Icon(Icons.search, color: AppColors.subtext.withOpacity(0.7)),
        filled: true,
        fillColor: AppColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
      style: TextStyle(color: AppColors.text),
    );
  }

  // Helper for an individual allergen pill
  Widget _buildAllergenPill({required String text, required Color dotColor}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(color: AppColors.text, fontSize: 14),
          ),
          const SizedBox(width: 8),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  // Helper for the "Your Allergens" section
  Widget _buildAllergenPillsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Text(
            'Your Allergens',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
        ),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: [
            _buildAllergenPill(text: 'Peanuts', dotColor: AppColors.alertRed),
            _buildAllergenPill(text: 'Dairy', dotColor: AppColors.warningYellow),
            _buildAllergenPill(text: 'Gluten', dotColor: AppColors.warningYellow),
            _buildAllergenPill(text: 'Shellfish', dotColor: AppColors.alertRed),
            _buildAllergenPill(text: 'Eggs', dotColor: AppColors.warningYellow),
            _buildAllergenPill(text: 'Tree Nuts', dotColor: AppColors.alertRed),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentScansSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Text(
            'Recent Scans',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
        ),
        if (_recentScans.isEmpty)
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.camera_alt_outlined,
                  size: 64,
                  color: AppColors.subtext.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  "No scans yet",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppColors.subtext,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Tap 'Scan Food or Product' to begin!",
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.subtext.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ..._recentScans.map((scan) => _buildScanResultCard(scan)),
      ],
    );
  }

  Widget _buildScanResultCard(ScanResult scan) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () {
          // Show detailed scan result dialog
          _showScanDetails(scan);
        },
        borderRadius: BorderRadius.circular(15),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                ),
                child: scan.imagePath.startsWith('assets')
                    ? Image.asset(
                  scan.imagePath,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                  ),
                )
                    : Image.file(
                  File(scan.imagePath),
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scan.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        scan.subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.subtext,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTimestamp(scan.timestamp),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.subtext.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: 40,
                decoration: BoxDecoration(
                  color: scan.statusColor,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                ),
                child: RotatedBox(
                  quarterTurns: 1,
                  child: Center(
                    child: Text(
                      scan.status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showScanDetails(ScanResult scan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(scan.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: scan.imagePath.startsWith('assets')
                  ? Image.asset(
                scan.imagePath,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              )
                  : Image.file(
                File(scan.imagePath),
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: scan.statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    scan.status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatTimestamp(scan.timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.subtext,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Analysis:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              scan.subtitle,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.text,
              ),
            ),
            if (scan.detectedAllergens.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Detected Allergens:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.alertRed,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                children: scan.detectedAllergens.map((allergen) => Chip(
                  label: Text(allergen),
                  backgroundColor: AppColors.alertRed.withOpacity(0.1),
                  labelStyle: TextStyle(
                    color: AppColors.alertRed,
                    fontSize: 12,
                  ),
                )).toList(),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TopHeaderSection(
          titlePrimary: 'Allergy',
          titleSecondary: 'Checker',
          description: 'Identify potential allergens in food and environment',
          imageAssetPath: null,
          gradientStart: AppColors.allergyGradientStart,
          gradientEnd: AppColors.allergyGradientEnd,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildScanFoodButton(context),
                const SizedBox(height: 16),
                _buildSearchBar(context),
                const SizedBox(height: 24),
                _buildAllergenPillsSection(context),
                const SizedBox(height: 24),
                _buildRecentScansSection(context),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }
}