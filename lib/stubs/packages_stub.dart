import 'dart:async';
import 'dart:typed_data';

// Stub implementations for packages functionality on web

enum BluetoothSignal { unknown, weak, normal, good, medium, strong }

enum PrinterStatus { 
  good, 
  lowBattery, 
  paperNotFound, 
  printing, 
  tooHot, 
  unknown;
  
  int get priority {
    switch (this) {
      case PrinterStatus.good:
        return 0;
      case PrinterStatus.lowBattery:
        return 1;
      case PrinterStatus.paperNotFound:
        return 2;
      case PrinterStatus.printing:
        return 1;
      case PrinterStatus.tooHot:
        return 2;
      case PrinterStatus.unknown:
        return 1;
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
  bool connected = false;
  
  BluetoothDevice({required this.name, required this.address});
  
  Stream<BluetoothSignal> createSignalStream() {
    return Stream.value(BluetoothSignal.normal);
  }
}

class PrinterManufactory {
  final String name;
  final int widthBits;
  final int feedPaperByteSize;
  
  const PrinterManufactory({required this.name, required this.widthBits, this.feedPaperByteSize = 1});
  
  static const cat1 = PrinterManufactory(name: 'CAT1', widthBits: 384);
  static const cat2 = PrinterManufactory(name: 'CAT2', widthBits: 576);
  
  static PrinterManufactory tryGuess(String name) {
    return PrinterManufactory(name: name, widthBits: 384);
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
  bool connected = false;
  final List<Function()> _listeners = [];
  late BluetoothDevice? device;
  
  Printer({required this.address, required this.manufactory, Printer? other}) {
    device = BluetoothDevice(name: 'Stub Printer', address: address);
  }
  
  void addListener(Function() listener) {
    _listeners.add(listener);
  }
  
  void removeListener(Function() listener) {
    _listeners.remove(listener);
  }
  
  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }
  
  Future<bool> connect() async {
    // Simulate connection for web
    await Future.delayed(Duration(milliseconds: 100));
    connected = true;
    _notifyListeners();
    return true;
  }
  
  Future<void> disconnect() async {
    // Simulate disconnection for web
    await Future.delayed(Duration(milliseconds: 100));
    connected = false;
    _notifyListeners();
  }
  
  Stream<double> draw(Uint8List bytes, {PrinterDensity? density}) {
    // Simulate drawing progress for web
    return Stream.fromIterable([0.0, 0.5, 1.0]);
  }
  
  Stream<PrinterStatus> get statusStream => Stream.value(PrinterStatus.good);
}

class BluetoothException implements Exception {
  final String message;
  final BluetoothExceptionCode code;
  final BluetoothExceptionFrom from;
  final String? description;
  final String? function;
  
  BluetoothException(this.message, {this.code = BluetoothExceptionCode.unknown, this.from = BluetoothExceptionFrom.unknown, this.description, this.function});
  
  @override
  String toString() => message;
}

class BluetoothOffException extends BluetoothException {
  BluetoothOffException() : super('Bluetooth is off');
}

class Bluetooth {
  static Stream<List<BluetoothDevice>> get scanResults => Stream.value([]);
  static Stream<bool> get isScanning => Stream.value(false);
  static Stream<bool> get adapterState => Stream.value(false);
  
  static Future<void> startScan() async {
    // Stub implementation for web
  }
  
  static Future<void> stopScan() async {
    // Stub implementation for web
  }
}