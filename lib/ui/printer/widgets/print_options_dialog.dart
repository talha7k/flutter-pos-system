import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:possystem/components/dialog/responsive_dialog.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/printer.dart';
import 'package:possystem/services/pdf_service.dart';
import 'package:possystem/translator.dart';

class PrintOptionsDialog extends StatelessWidget {
  final OrderObject order;

  const PrintOptionsDialog({
    super.key,
    required this.order,
  });

  static Future<void> show(BuildContext context, OrderObject order) async {
    await showDialog(
      context: context,
      builder: (context) => PrintOptionsDialog(order: order),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasConnectedPrinters = Printers.instance.hasConnected;
    
    return ResponsiveDialog(
      title: Text(S.printerOptionsTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(S.printerOptionsDescription),
          const SizedBox(height: 16),
          
          // Bluetooth printing option
          Card(
            child: ListTile(
              leading: Icon(
                hasConnectedPrinters 
                  ? Icons.bluetooth_connected 
                  : Icons.bluetooth_disabled,
                color: hasConnectedPrinters 
                  ? Theme.of(context).colorScheme.primary 
                  : Theme.of(context).disabledColor,
              ),
              title: Text(S.printerOptionsBluetooth),
              subtitle: Text(
                hasConnectedPrinters 
                  ? S.printerOptionsBluetoothAvailable 
                  : S.printerOptionsBluetoothUnavailable,
              ),
              trailing: hasConnectedPrinters 
                ? const Icon(Icons.arrow_forward_ios) 
                : null,
              onTap: hasConnectedPrinters 
                ? () => _handleBluetoothPrint(context) 
                : null,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // PDF printing option
          Card(
            child: ListTile(
              leading: Icon(
                Icons.picture_as_pdf,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(S.printerOptionsPdf),
              subtitle: Text(S.printerOptionsPdfDescription),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _handlePdfPrint(context),
            ),
          ),
        ],
      ),
    );
  }

  void _handleBluetoothPrint(BuildContext context) async {
    Navigator.of(context).pop();
    
    try {
      // Use existing Bluetooth printing logic
      final receipt = await Printers.instance.generateReceipts(
        context: context, 
        order: order,
      );
      
      if (receipt != null) {
        Printers.instance.printReceipts(receipt);
        if (context.mounted) {
          showSnackBar(
          S.printerOptionsSuccessBluetoothPrint, 
          context: context,
        );
        }
      }
    } catch (e) {
      Log.err('bluetooth_print_error', e.toString());
      if (context.mounted) {
        showSnackBar(
          S.printerOptionsErrorBluetoothPrint, 
          context: context,
        );
      }
    }
  }

  void _handlePdfPrint(BuildContext context) async {
    Navigator.of(context).pop();
    
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Material(
          color: Colors.transparent,
          child: Center(
            child: CircularProgressIndicator.adaptive(),
          ),
        ),
      );
      
      // Generate PDF
      final pdfBytes = await PdfService.generateReceiptPdf(order);
      
      // Close loading indicator
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      
      // Show PDF options
      if (context.mounted) {
        await _showPdfOptions(context, pdfBytes);
      }
    } catch (e) {
      Log.err('pdf_print_error', e.toString());
      
      // Close loading indicator
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      
      if (context.mounted) {
        showSnackBar(
          S.printerOptionsErrorPdfGeneration, 
          context: context,
        );
      }
    }
  }

  Future<void> _showPdfOptions(BuildContext context, List<int> pdfBytes) async {
    await showDialog(
      context: context,
      builder: (context) => ResponsiveDialog(
        title: Text(S.printerPdfTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.preview),
              title: Text(S.printerPdfPreview),
              subtitle: Text(S.printerPdfPreviewDescription),
              onTap: () async {
                Navigator.of(context).pop();
                await PdfService.previewPdf(
                  Uint8List.fromList(pdfBytes), 
                  'Receipt_${order.id}',
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: Text(S.printerPdfShare),
              subtitle: Text(S.printerPdfShareDescription),
              onTap: () async {
                Navigator.of(context).pop();
                await PdfService.shareOrPrintPdf(
                  Uint8List.fromList(pdfBytes), 
                  'Receipt_${order.id}',
                );
                if (context.mounted) {
                  showSnackBar(
                  S.printerOptionsSuccessPdfGenerated, 
                  context: context,
                );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.save),
              title: Text(S.printerPdfSave),
              subtitle: Text(S.printerPdfSaveDescription),
              onTap: () async {
                Navigator.of(context).pop();
                try {
                  final filePath = await PdfService.savePdfToDevice(
                    Uint8List.fromList(pdfBytes), 
                    'Receipt_${order.id}',
                  );
                  if (context.mounted) {
                    showSnackBar(
                      S.printerOptionsSuccessPdfSaved(filePath), 
                      context: context,
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    showSnackBar(
                      S.printerOptionsErrorPdfSave, 
                      context: context,
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}