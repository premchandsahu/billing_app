import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
//import 'package:share_plus/share_plus.dart';

class InvoiceShareService {
  static Future<void> shareInvoicePdf({
    required Uint8List pdfBytes,
    required int invoiceNo,
  }) async {
    final directory = await getTemporaryDirectory();

    final file = File('${directory.path}/Invoice_$invoiceNo.pdf');

    await file.writeAsBytes(pdfBytes);

    //  await SharePlus.instance.share(
    //    ShareParams(text: 'Invoice No: $invoiceNo', files: [XFile(file.path)]),
    //  );
  }
}
