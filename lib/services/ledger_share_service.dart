import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class LedgerShareService {
  static Future<void> shareLedgerPdf({
    required Uint8List pdfBytes,
    required String customername,
    required String message,
  }) async {
    final directory = await getTemporaryDirectory();

    final filePath = '${directory.path}/Ledger_$customername.pdf';

    final file = File(filePath);

    await file.writeAsBytes(pdfBytes, flush: true);

    final params = ShareParams(
      title: 'Ledger_$customername.pdf',
      text: message,
      files: [XFile(file.path, mimeType: 'application/pdf')],
    );

    await SharePlus.instance.share(params);
  }
}
