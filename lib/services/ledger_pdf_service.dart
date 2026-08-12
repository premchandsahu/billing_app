import 'dart:typed_data';

import 'package:billing_app/models/account_transaction.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class LedgerPdfService {
  static Future<Uint8List> generatePdf({
    required DateTime fromdate,
    required DateTime todate,
    required int custno,
    required String customername,
    required double openingbalance,
    required List<AccountTransaction> items,
  }) async {
    final pdf = pw.Document();
    final DateFormat df = DateFormat("dd-MM-yy");
    double totald = 0;
    double totalc = 0;

    for (final item in items) {
      totald += item.invoiceamount;
      totalc += item.receiptamount;
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (context) {
          return [
            pw.Center(
              child: pw.Text(
                'Jai Hind Enterprises',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.Center(
              child: pw.Text(
                'Account Ledger',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),

            pw.SizedBox(height: 15),

            pw.Text(
              'Customer: $customername.   Period ${df.format(fromdate)} to ${df.format(todate)}',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 15),
            pw.Row(
              //crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
              children: [
                pw.Text("Op. Bal: $openingbalance"),
                pw.Text("Sale: $totald"),
                pw.Text("Rcpts: $totalc"),
                pw.Text("Cl Bal: ${openingbalance + totald - totalc}"),
              ],
            ),

            pw.SizedBox(height: 2),
            // ignore: deprecated_member_use
            pw.Table.fromTextArray(
              headers: const ['T No', 'T Date', 'Remarks', 'Debit', 'Credit'],
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.centerLeft,
                3: pw.Alignment.centerRight,
                4: pw.Alignment.centerRight,
              },

              columnWidths: {
                0: const pw.FlexColumnWidth(10), // Fixed width of 40 points
                1: const pw.FlexColumnWidth(
                  10,
                ), // Takes 2 parts of remaining space
                2: const pw.FlexColumnWidth(
                  40,
                ), // Takes 4 parts of remaining space (wider)
                3: const pw.FlexColumnWidth(
                  10,
                ), // Sizes exactly to its content width
                4: const pw.FlexColumnWidth(10),
              },
              data: items.map((item) {
                return [
                  item.tno,
                  df.format(item.tdate),
                  item.remarks,
                  item.invoiceamount,
                  item.receiptamount,
                ];
              }).toList(),
            ),

            pw.SizedBox(height: 20),

            //          pw.Align(
            //            alignment: pw.Alignment.centerRight,
            //            child: pw.Text(
            //              'Grand Total: ₹ ${total.toStringAsFixed(2)}',
            //              style: pw.TextStyle(
            //                fontSize: 16,
            //                fontWeight: pw.FontWeight.bold,
            //              ),
            //            ),
            //          ),
          ];
        },
      ),
    );

    return pdf.save();
  }
}
