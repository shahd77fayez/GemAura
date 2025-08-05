// lib/src/features/conditions/screens/blind_assist_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp; // <--- Add 'as fbp'
import 'package:gemma_final_app/src/config/theme.dart';
import 'package:gemma_final_app/src/shared_widgets/top_header_section.dart';
import 'package:gemma_final_app/src/shared_widgets/bluetooth_button.dart';
import 'package:gemma_final_app/src/shared_widgets/feature_card.dart';
import 'package:gemma_final_app/src/config/app_router.dart';
import 'package:gemma_final_app/src/features/conditions/blind_assist/screens/model_management_screen.dart';
import 'package:gemma_final_app/src/features/conditions/blind_assist/services/bluetooth_service.dart'; // Import your service

class BlindAssistScreen extends StatefulWidget {
  const BlindAssistScreen({super.key});

  @override
  State<BlindAssistScreen> createState() => _BlindAssistScreenState();
}

class _BlindAssistScreenState extends State<BlindAssistScreen> {
  final BluetoothService _bluetoothService = BluetoothService();
  fbp.BluetoothDevice? _selectedDevice; // <--- Use 'fbp.BluetoothDevice'
  bool _isScanning = false;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    // Start listening to the connection state
    _bluetoothService.deviceConnectionState?.listen((state) {
      if (state == fbp.BluetoothConnectionState.connected) {
        if (mounted) {
          setState(() => _isConnected = true);
        }
      } else {
        if (mounted) {
          setState(() => _isConnected = false);
        }
      }
    });
  }

  Future<void> _handleBluetoothConnection() async {
    // First, check if Bluetooth is on
    if (!await fbp.FlutterBluePlus.isSupported) { // <--- Use fbp.FlutterBluePlus
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bluetooth not supported on this device')),
        );
      }
      return;
    }

    if (!await fbp.FlutterBluePlus.isOn) { // <--- Use fbp.FlutterBluePlus
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please turn on Bluetooth')),
        );
      }
      return;
    }

    if (_isConnected) {
      // If already connected, disconnect
      await _bluetoothService.disconnectFromDevice();
      setState(() {
        _isConnected = false;
        _selectedDevice = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Disconnected from device')),
        );
      }
    } else {
      // If not connected, start the connection process
      await _scanAndConnect();
    }
  }

  Future<void> _scanAndConnect() async {
    setState(() => _isScanning = true);
    try {
      final devices = await _bluetoothService.scanForDevices();
      setState(() => _isScanning = false);

      if (devices.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No Bluetooth devices found')),
          );
        }
        return;
      }

      final selectedDevice = await showDialog<fbp.BluetoothDevice>( // <--- Use fbp.BluetoothDevice
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Select a Bluetooth Device'),
          content: SingleChildScrollView(
            child: Column(
              children: devices.map((d) {
                // Corrected logic using platformName
                final deviceName = d.platformName.isNotEmpty ? d.platformName : 'Unknown Device';
                final subtitleText = 'ID: ${d.remoteId.str}';

                return ListTile(
                  title: Text(deviceName),
                  subtitle: Text(subtitleText),
                  onTap: () => Navigator.of(context).pop(d),
                );
              }).toList(),
            ),
          ),
// ...
        ),
      );

      if (selectedDevice != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Connecting to ${selectedDevice.localName}...')),
          );
        }
        await _bluetoothService.connectToDevice(selectedDevice);
        setState(() {
          _selectedDevice = selectedDevice;
          _isConnected = true;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Connected to ${selectedDevice.localName}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to connect: $e')),
        );
      }
      setState(() => _isScanning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TopHeaderSection(
          titlePrimary: 'Blind Assist',
          titleSecondary: 'Helper',
          description: 'Empowering independence and enhancing safety for the visually impaired.',
          imageAssetPath: null,
          gradientStart: AppColors.blindGradientStart,
          gradientEnd: AppColors.blindGradientEnd,
        ),
        const SizedBox(height: 10),
        _isScanning
            ? const Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        )
            : BluetoothButton(
          buttonColor: _isConnected ? Colors.green : AppColors.blindPrimary,
          onPressed: _handleBluetoothConnection,
          isConnected: _isConnected, // <--- Pass the state here
        ),
        const SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            _isConnected
                ? "Connected to ${_selectedDevice!.localName}."
                : "You can control your hardware device remotely through Bluetooth using Gemma for seamless assistance.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.subtext.withOpacity(0.9),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: SingleChildScrollView(
            child: Container(
              color: AppColors.background,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 8.0),
                    child: Text(
                      'Features',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                  FeatureCard(
                    icon: Icons.chat_bubble_outline,
                    title: 'Blind Assist Overview',
                    description: 'Learn how to get the most out of your assistant.',
                    accentColor: AppColors.blindPrimary,
                    onTap: () {
                      AppRouter.navigateTo(context, AppRouter.blindAssistOverviewRoute);
                    },
                  ),
                  FeatureCard(
                    icon: Icons.camera_alt_outlined,
                    title: 'Start Blind Assist',
                    description: 'Get real-time assistance with object recognition, navigation, and more.',
                    accentColor: AppColors.blindPrimary,
                    onTap: () {
                      AppRouter.navigateTo(context, AppRouter.blindAssistFunctionalityRoute);
                    },
                  ),
                  FeatureCard(
                    icon: Icons.library_books_outlined,
                    title: 'How to Use',
                    description: 'Step-by-step guides and tutorials for all features.',
                    accentColor: AppColors.blindPrimary,
                    onTap: () {
                      AppRouter.navigateTo(context, AppRouter.howToUseRoute);
                    },
                  ),
                  FeatureCard(
                    icon: Icons.storage,
                    title: 'Manage AI Model',
                    description: 'Download, update, or remove the AI model.',
                    accentColor: AppColors.blindPrimary,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ModelManagementScreen(isAutoNavigate: false)),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}