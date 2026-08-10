import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/invoice_item.dart';
import '../models/customer.dart';

class InvoicePdfService {
  static Future<Uint8List> generateInvoicePdf({
    required int invoiceNo,
    required DateTime invoiceDate,
    required Customer customer,
    required List<InvoiceItem> items,
  }) async {
    final pdf = pw.Document();

    double total = 0;

    for (final item in items) {
      total += item.qty * item.rate;
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (context) {
          return [
            pw.Center(
              child: pw.Text(
                'INVOICE',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),

            pw.SizedBox(height: 20),

            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Invoice No: $invoiceNo'),
                pw.Text(
                  'Date: ${invoiceDate.day.toString().padLeft(2, '0')}-'
                  '${invoiceDate.month.toString().padLeft(2, '0')}-'
                  '${invoiceDate.year}',
                ),
              ],
            ),

            pw.SizedBox(height: 15),

            pw.Text(
              'Customer',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),

            pw.Text(customer.customername),

            pw.SizedBox(height: 20),

            // ignore: deprecated_member_use
            pw.Table.fromTextArray(
              headers: const ['Product', 'Qty', 'Rate', 'Amount'],
              data: items.map((item) {
                final amount = item.qty * item.rate;

                return [
                  item.product?.name ?? '',
                  item.qty.toString(),
                  item.rate.toStringAsFixed(2),
                  amount.toStringAsFixed(2),
                ];
              }).toList(),
            ),

            pw.SizedBox(height: 20),

            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'Grand Total: ₹ ${total.toStringAsFixed(2)}',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }
}
