import 'dart:typed_data';

import 'package:printing/printing.dart';

class InvoicePrintService {
  static Future<void> printInvoice(Uint8List pdfBytes) async {
    await Printing.layoutPdf(
      onLayout: (format) async {
        return pdfBytes;
      },
    );
  }
}
