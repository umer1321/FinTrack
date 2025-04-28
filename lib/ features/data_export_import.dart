import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fintrack/core/models/transaction_model.dart';
import 'package:fintrack/core/models/budget_model.dart';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class DataExportImport {
  Future<String?> exportData(List<Transaction> transactions, List<Budget> budgets) async {
    // Request permission for Android 12 and lower
    if (Platform.isAndroid && !(await _isAndroid13OrAbove())) {
      PermissionStatus status = await Permission.storage.request();
      if (status != PermissionStatus.granted) {
        return null;
      }
    }

    // Prepare CSV
    List<List<dynamic>> transactionRows = [
      ['ID', 'User ID', 'Amount (SAR)', 'Type', 'Category', 'Date', 'Description'],
      ...transactions.map((t) => [
        t.id,
        t.userId,
        t.amount,
        t.type,
        t.category,
        t.date.toIso8601String(),
        t.description,
      ]),
    ];

    List<List<dynamic>> budgetRows = [
      ['ID', 'User ID', 'Category', 'Amount (SAR)', 'Month'],
      ...budgets.map((b) => [
        b.id,
        b.userId,
        b.category,
        b.amount,
        b.month,
      ]),
    ];

    String transactionCsv = const ListToCsvConverter().convert(transactionRows);
    String budgetCsv = const ListToCsvConverter().convert(budgetRows);

    String combinedCsv = 'Transactions\n$transactionCsv\n\nBudgets\n$budgetCsv';

    // Save CSV into app's document folder
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String filePath = '${appDocDir.path}/fintrack_data_${DateTime.now().millisecondsSinceEpoch}.csv';

    final file = File(filePath);
    await file.writeAsString(combinedCsv);

    return file.path;
  }

  Future<Map<String, List<dynamic>>?> importData() async {
    if (Platform.isAndroid && !(await _isAndroid13OrAbove())) {
      PermissionStatus status = await Permission.storage.request();
      if (status != PermissionStatus.granted) {
        return null;
      }
    }

    // Pick file manually
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result == null || result.files.single.path == null) return null;

    final file = File(result.files.single.path!);
    String csvString = await file.readAsString();

    List<String> sections = csvString.split('\n\n');
    if (sections.length < 2) {
      throw Exception('Invalid format: Expected "Transactions" and "Budgets" sections.');
    }

    List<Transaction> transactions = [];
    if (sections[0].startsWith('Transactions')) {
      List<List<dynamic>> transactionRows = const CsvToListConverter().convert(
        sections[0].replaceFirst('Transactions\n', ''),
        eol: '\n',
      );
      for (int i = 1; i < transactionRows.length; i++) {
        final row = transactionRows[i];
        if (row.length >= 7) {
          transactions.add(Transaction(
            id: row[0].toString(),
            userId: row[1].toString(),
            amount: double.parse(row[2].toString()),
            type: row[3].toString(),
            category: row[4].toString(),
            date: DateTime.parse(row[5].toString()),
            description: row[6].toString(),
          ));
        }
      }
    }

    List<Budget> budgets = [];
    if (sections[1].startsWith('Budgets')) {
      List<List<dynamic>> budgetRows = const CsvToListConverter().convert(
        sections[1].replaceFirst('Budgets\n', ''),
        eol: '\n',
      );
      for (int i = 1; i < budgetRows.length; i++) {
        final row = budgetRows[i];
        if (row.length >= 5) {
          budgets.add(Budget(
            id: row[0].toString(),
            userId: row[1].toString(),
            category: row[2].toString(),
            amount: double.parse(row[3].toString()),
            month: row[4].toString(),
          ));
        }
      }
    }

    return {
      'transactions': transactions,
      'budgets': budgets,
    };
  }

  Future<bool> _isAndroid13OrAbove() async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.version.sdkInt >= 33;
    }
    return false;
  }
}
