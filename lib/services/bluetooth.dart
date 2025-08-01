import 'dart:async';

import 'package:possystem/adapters/bluetooth_adapter.dart' as bt;

typedef BluetoothSignal = bt.BluetoothSignal;
typedef PrinterStatus = bt.PrinterStatus;
typedef PrinterDensity = bt.PrinterDensity;
typedef BluetoothException = bt.BluetoothException;
typedef BluetoothExceptionCode = bt.BluetoothExceptionCode;
typedef BluetoothExceptionFrom = bt.BluetoothExceptionFrom;
typedef BluetoothOffException = bt.BluetoothOffException;

class Bluetooth {
  static Bluetooth instance = Bluetooth();

  Bluetooth();

  /// Timeout in 3 minutes
  Stream<List<bt.BluetoothDevice>> startScan() => bt.Bluetooth.scanResults;

  Future<void> stopScan() => bt.Bluetooth.stopScan();
}
