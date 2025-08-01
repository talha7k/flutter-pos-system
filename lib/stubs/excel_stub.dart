// Stub implementation for Excel functionality on web

class CellValue {
  final String? string;
  final num? number;
  
  CellValue({this.string, this.number});
  
  dynamic get value => string ?? number;
}

class TextCellValue extends CellValue {
  TextCellValue(String value) : super(string: value);
}

class DoubleCellValue extends CellValue {
  DoubleCellValue(double value) : super(number: value);
}

class CellIndex {
  final int columnIndex;
  final int rowIndex;
  
  CellIndex({required this.columnIndex, required this.rowIndex});
  
  static CellIndex indexByColumnRow({required int columnIndex, required int rowIndex}) {
    return CellIndex(columnIndex: columnIndex, rowIndex: rowIndex);
  }
}

class Sheet {
  final String name;
  final Map<String, CellValue> _cells = {};
  
  Sheet(this.name);
  
  void updateCell(CellIndex index, CellValue value) {
    _cells['${index.columnIndex}_${index.rowIndex}'] = value;
  }
  
  List<List<CellValue?>> get rows {
    // Return empty for web stub
    return [];
  }
}

class Excel {
  final Map<String, Sheet> _sheets = {};
  
  Excel._();
  
  static Excel createExcel() {
    return Excel._();
  }
  
  static Excel decodeBytes(List<int> bytes) {
    return Excel._();
  }
  
  Map<String, Sheet> get sheets => _sheets;
  
  Sheet operator [](String sheetName) {
    return _sheets.putIfAbsent(sheetName, () => Sheet(sheetName));
  }
  
  void delete(String sheetName) {
    _sheets.remove(sheetName);
  }
  
  void setDefaultSheet(String sheetName) {
    // Stub implementation - no-op for web
  }
  
  List<int> encode() {
    // Return empty bytes for web stub
    return [];
  }
}