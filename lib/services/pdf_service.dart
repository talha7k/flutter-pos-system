import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/translator.dart';
import 'package:printing/printing.dart';

class PdfService {
  static const String _qrCodePrefix = 'ZATCA-';
  
  /// Generate a PDF receipt with QR code for ZATCA compliance
  static Future<Uint8List> generateReceiptPdf(OrderObject order) async {
    final pdf = pw.Document();
    
    // Generate QR code data for ZATCA compliance
    final qrData = _generateZatcaQrData(order);
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        margin: const pw.EdgeInsets.all(8),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Center(
                child: pw.Text(
                  S.printerReceiptTitle,
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 8),
              
              // Date and time
              pw.Center(
                child: pw.Text(
                  DateFormat('yyyy MMM dd - HH:mm:ss').format(order.createdAt),
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ),
              pw.SizedBox(height: 12),
              
              // Order items table
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(1),
                  2: const pw.FlexColumnWidth(1.5),
                  3: const pw.FlexColumnWidth(1.5),
                },
                children: [
                  // Header row
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _buildTableCell(S.printerReceiptColumnName, isHeader: true),
                      _buildTableCell(S.printerReceiptColumnCount, isHeader: true),
                      _buildTableCell(S.printerReceiptColumnPrice, isHeader: true),
                      _buildTableCell(S.printerReceiptColumnTotal, isHeader: true),
                    ],
                  ),
                  // Product rows
                  for (final product in order.products)
                    pw.TableRow(
                      children: [
                        _buildTableCell(product.productName),
                        _buildTableCell(product.count.toString()),
                        _buildTableCell('\$${product.singlePrice.toCurrency()}'),
                        _buildTableCell('\$${product.totalPrice.toCurrency()}'),
                      ],
                    ),
                ],
              ),
              pw.SizedBox(height: 12),
              
              // Discounts section
              if (order.products.any((e) => e.isDiscount)) ...[
                pw.Text(
                  S.printerReceiptDiscountLabel,
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 4),
                for (final product in order.products.where((e) => e.isDiscount))
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('  ${product.productName}'),
                      pw.Text('\$${product.originalPrice.toCurrency()}'),
                    ],
                  ),
                pw.SizedBox(height: 8),
              ],
              
              // Attributes section
              if (order.attributes.any((e) => e.modeValue != null)) ...[
                pw.Text(
                  S.printerReceiptAddOnsLabel,
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 4),
                for (final attr in order.attributes.where((e) => e.modeValue != null))
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('  ${attr.optionName}'),
                      pw.Text(attr.modeValue.toString()),
                    ],
                  ),
                pw.SizedBox(height: 8),
              ],
              
              // Total section
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    S.printerReceiptTotal,
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    '\$${order.price.toCurrency()}',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              
              // Payment details
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(S.printerReceiptPaid),
                      pw.Text('  ${S.printerReceiptPrice}'),
                      pw.Text('  ${S.printerReceiptChange}'),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('\$${order.paid.toCurrency()}'),
                      pw.Text('\$${order.price.toCurrency()}'),
                      pw.Text('\$${order.change.toCurrency()}'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
              
              // QR Code for ZATCA compliance
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'ZATCA QR Code',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.BarcodeWidget(
                      barcode: pw.Barcode.qrCode(),
                      data: qrData,
                      width: 80,
                      height: 80,
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Order ID: ${order.id}',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
    
    return pdf.save();
  }
  
  /// Save PDF to device storage and return the file path
  static Future<String> savePdfToDevice(Uint8List pdfBytes, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName.pdf');
    await file.writeAsBytes(pdfBytes);
    return file.path;
  }
  
  /// Share or print PDF using the printing package
  static Future<void> shareOrPrintPdf(Uint8List pdfBytes, String title) async {
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: '$title.pdf',
    );
  }
  
  /// Preview PDF before printing
  static Future<void> previewPdf(Uint8List pdfBytes, String title) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: title,
    );
  }
  
  /// Generate ZATCA compliant QR code data
  static String _generateZatcaQrData(OrderObject order) {
    // ZATCA QR code format includes:
    // 1. Seller name
    // 2. VAT registration number
    // 3. Timestamp
    // 4. Invoice total
    // 5. VAT amount
    
    final timestamp = DateFormat('yyyy-MM-ddTHH:mm:ssZ').format(order.createdAt);
    final vatAmount = (order.price * 0.15).toCurrencyNum(); // Assuming 15% VAT
    
    return '$_qrCodePrefix'
        'SELLER:POS System|'
        'VAT:123456789|'
        'TIME:$timestamp|'
        'TOTAL:\$${order.price.toCurrency()}|'
        'VAT:\$${vatAmount.toCurrency()}|'
        'ORDER:${order.id}';
  }
  
  /// Helper method to build table cells
  static pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 10 : 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: isHeader ? pw.TextAlign.center : pw.TextAlign.left,
      ),
    );
  }
}