// lib/src/shared_widgets/bluetooth_button.dart
import 'package:flutter/material.dart';
import 'package:gemma_final_app/src/config/theme.dart';

class BluetoothButton extends StatelessWidget {
  final Color buttonColor;
  final VoidCallback? onPressed;
  final bool isConnected; // <--- Add a new parameter to hold the state

  const BluetoothButton({
    super.key,
    required this.buttonColor,
    this.onPressed,
    this.isConnected = false, // <--- Give it a default value
  });

  @override
  Widget build(BuildContext context) {
    // Use a ternary operator to choose the button text
    final buttonText = isConnected ? 'Disconnect Bluetooth' : 'Connect Bluetooth';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.bluetooth, color: Colors.white, size: 24),
        label: Text(
          buttonText, // Use the new variable for the label
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 5,
          minimumSize: const Size(double.infinity, 50),
        ),
      ),
    );
  }
}