import 'package:csv/csv.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class CsvExporter {
  static Future<void> exportData({
    required String filename,
    required List<List<dynamic>> rows,
  }) async {
    try {
      // csv v8+ uses the global `csv` instance with `csv.encode()`
      final String csvData = csv.encode(rows);
      final Uint8List bytes = Uint8List.fromList(csvData.codeUnits);

      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final String finalFilename = '${filename}_$timestamp';

      await FileSaver.instance.saveFile(
        name: finalFilename,
        bytes: bytes,
        fileExtension: 'csv',
        mimeType: MimeType.csv,
      );
    } catch (e) {
      debugPrint('Error exporting CSV: $e');
      rethrow;
    }
  }
}
