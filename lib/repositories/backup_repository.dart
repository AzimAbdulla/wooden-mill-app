import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wooden_mill_app/database/db_helper.dart';
import 'package:wooden_mill_app/models/order.dart';
import 'package:wooden_mill_app/repositories/order_repository.dart';

class BackupRepository {
  static const String _lastBackupKey = 'last_backup_timestamp';
  static const String _appName = 'Timbr';

  final OrderRepository _orderRepository = OrderRepository();

  /// Backup file contents for [orders], including every log row.
  static String encodeBackup(List<OrderModel> orders) {
    return jsonEncode({
      'version': 2,
      'app': _appName,
      'createdAt': DateTime.now().toIso8601String(),
      'orders': orders.map((o) => o.toBackupMap()).toList(),
    });
  }

  /// Orders in a backup file. Throws [FormatException] if it isn't a Timbr backup.
  static List<OrderModel> decodeBackup(String json) {
    final data = jsonDecode(json);
    if (data is! Map || data['app'] != _appName || data['orders'] is! List) {
      throw const FormatException('Not a Timbr backup file');
    }
    return (data['orders'] as List)
        .map((o) => OrderModel.fromBackupMap(Map<String, dynamic>.from(o as Map)))
        .toList();
  }

  static String backupFileName() {
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    return 'Timbr_Backup_$timestamp.json';
  }

  /// JSON backup of every order and its logs.
  Future<String> createBackup() async {
    return encodeBackup(await _orderRepository.getAllOrders());
  }

  /// Replaces all orders and logs with the contents of a backup, in one transaction.
  /// Returns the number of orders restored.
  Future<int> restoreBackup(String json) async {
    final orders = decodeBackup(json);

    final db = await DbHelper.instance.database;
    await db.transaction((txn) async {
      await txn.delete('LogDimensions');
      await txn.delete('Orders');

      for (final order in orders) {
        // Keeps the original id so order numbers on printed receipts still match.
        final orderId = await txn.insert('Orders', order.toMap());
        for (final log in order.logs) {
          await txn.insert('LogDimensions', {
            'orderId': orderId,
            'length': log.length,
            'girth': log.girth,
            'volume': log.volume,
            'price': log.price,
          });
        }
      }
    });

    return orders.length;
  }

  Future<void> markBackupDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastBackupKey, DateTime.now().toIso8601String());
  }

  /// Retrieves timestamp of last successful backup
  Future<DateTime?> getLastBackupTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString(_lastBackupKey);
      if (str != null) {
        return DateTime.tryParse(str);
      }
    } catch (_) {}
    return null;
  }
}
