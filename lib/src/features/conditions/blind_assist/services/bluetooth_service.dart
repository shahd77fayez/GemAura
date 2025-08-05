import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothService {
  BluetoothService._();
  static final BluetoothService _instance = BluetoothService._();
  factory BluetoothService() => _instance;

  BluetoothDevice? connectedDevice;

  Stream<BluetoothAdapterState> get adapterState => FlutterBluePlus.adapterState;

  Stream<BluetoothConnectionState>? get deviceConnectionState => connectedDevice?.connectionState;

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect(timeout: const Duration(seconds: 15));
      connectedDevice = device;
      print('Connected to ${device.platformName}');
      // You can discover services here if needed
    } catch (e) {
      print('Error connecting to device: $e');
      rethrow;
    }
  }

  Future<void> disconnectFromDevice() async {
    if (connectedDevice != null) {
      await connectedDevice!.disconnect();
      connectedDevice = null;
      print('Disconnected from device');
    }
  }

  Future<List<BluetoothDevice>> scanForDevices() async {
    List<BluetoothDevice> devices = [];
    try {
      FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));

      FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult result in results) {
          // This is the updated, non-filtering condition.
          // It adds every unique device to the list.
          if (!devices.any((d) => d.id == result.device.id)) {
            devices.add(result.device);
          }
        }
      });

      await FlutterBluePlus.isScanning.where((val) => val == false).first;
    } catch (e) {
      print('Error scanning for devices: $e');
      rethrow;
    }
    return devices;
  }
}