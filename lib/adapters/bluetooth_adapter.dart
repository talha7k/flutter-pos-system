import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;

// Adapter to bridge the gap between the original custom packages and flutter_blue_plus

enum BluetoothSignal { weak, normal, good, strong }

enum PrinterStatus { 
  idle, 
  printing, 
  error, 
  disconnected;
  
  int get priority {
    switch (this) {
      case PrinterStatus.error:
        return 3;
      case PrinterStatus.printing:
        return 2;
      case PrinterStatus.disconnected:
        return 1;
      case PrinterStatus.idle:
        return 0;
    }
  }
}

enum PrinterDensity { light, normal, tight, dark }

enum BluetoothExceptionCode { 
  unknown, 
  deviceNotFound, 
  connectionFailed, 
  timeout, 
  deviceIsDisconnected, 
  serviceNotFound, 
  characteristicNotFound, 
  adapterIsOff, 
  connectionCanceled, 
  userRejected 
}

enum BluetoothExceptionFrom { unknown, system, device }

class BluetoothDevice {
  final String name;
  final String address;
  final fbp.BluetoothDevice _device;
  
  BluetoothDevice({required this.name, required this.address, required fbp.BluetoothDevice device}) 
    : _device = device;
  
  bool get connected => _device.isConnected;
  
  Stream<BluetoothSignal> createSignalStream() {
    return _device.connectionState.map((state) {
      switch (state) {
        case fbp.BluetoothConnectionState.connected:
          return BluetoothSignal.good;
        case fbp.BluetoothConnectionState.disconnected:
          return BluetoothSignal.weak;
        default:
          return BluetoothSignal.normal;
      }
    });
  }
}

abstract class PrinterManufactory {
  final String name;
  final int widthBits;
  final int feedPaperByteSize;
  
  const PrinterManufactory({required this.name, required this.widthBits, this.feedPaperByteSize = 1});
  
  static PrinterManufactory? tryGuess(String name) {
    if (name.toLowerCase().contains('cat')) {
      return const CatPrinter();
    }
    return null;
  }
  
  @override
  String toString() => name;
}

class CatPrinter extends PrinterManufactory {
  const CatPrinter({int feedPaperByteSize = 1}) : super(name: 'CAT', widthBits: 384, feedPaperByteSize: feedPaperByteSize);
}

class Printer {
  final String address;
  final PrinterManufactory manufactory;
  BluetoothDevice? _device;
  final List<VoidCallback> _listeners = [];
  
  Printer({required this.address, required this.manufactory, Printer? other}) {
    // Initialize with a mock device for now
    _device = BluetoothDevice(name: 'Printer', address: address, device: fbp.BluetoothDevice.fromId('mock_$address'));
  }
  
  bool get connected => _device?.connected ?? false;
  
  Stream<BluetoothSignal> get statusStream => _device?.createSignalStream() ?? Stream.value(BluetoothSignal.normal);
  
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }
  
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }
  
  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }
  
  Future<bool> connect() async {
    try {
      if (_device != null) {
        await _device!._device.connect();
        _notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      throw BluetoothException('Connection failed: $e');
    }
  }
  
  Future<void> disconnect() async {
    if (_device != null) {
      await _device!._device.disconnect();
      _notifyListeners();
    }
  }
  
  Stream<double> draw(Uint8List image, {PrinterDensity? density}) async* {
    // Mock implementation - yield progress values
    for (int i = 0; i <= 100; i += 10) {
      await Future.delayed(const Duration(milliseconds: 50));
      yield i / 100.0;
    }
  }
}

class BluetoothException implements Exception {
  final String message;
  final BluetoothExceptionCode code;
  final BluetoothExceptionFrom from;
  final String? description;
  final String? function;
  
  BluetoothException(this.message, {
    this.code = BluetoothExceptionCode.unknown, 
    this.from = BluetoothExceptionFrom.unknown, 
    this.description, 
    this.function
  });
  
  @override
  String toString() => message;
}

class BluetoothOffException extends BluetoothException {
  BluetoothOffException() : super('Bluetooth is off', code: BluetoothExceptionCode.adapterIsOff);
}

class Bluetooth {
  static Stream<List<BluetoothDevice>> get scanResults {
    return fbp.FlutterBluePlus.scanResults.map((results) {
      return results.map((result) {
        return BluetoothDevice(
          name: result.device.platformName.isEmpty ? 'Unknown Device' : result.device.platformName,
          address: result.device.remoteId.str,
          device: result.device,
        );
      }).toList();
    });
  }
  
  static Future<void> startScan() async {
    await fbp.FlutterBluePlus.startScan(timeout: Duration(seconds: 4));
  }
  
  static Future<void> stopScan() async {
    await fbp.FlutterBluePlus.stopScan();
  }
}