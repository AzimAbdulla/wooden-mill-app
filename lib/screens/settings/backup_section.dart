import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wooden_mill_app/core/theme/shadcn_tokens.dart';
import 'package:wooden_mill_app/core/utils/export_helper.dart';
import 'package:wooden_mill_app/repositories/backup_repository.dart';
import 'package:wooden_mill_app/repositories/order_repository.dart';
import 'package:wooden_mill_app/widgets/app_dialogs.dart';
import 'package:wooden_mill_app/widgets/app_section.dart';
import 'package:wooden_mill_app/widgets/key_value_row.dart';

/// Backup, restore and export of the order history.
class BackupSection extends StatefulWidget {
  const BackupSection({super.key});

  @override
  State<BackupSection> createState() => _BackupSectionState();
}

class _BackupSectionState extends State<BackupSection> {
  final BackupRepository _backupRepository = BackupRepository();
  DateTime? _lastBackupTime;

  @override
  void initState() {
    super.initState();
    _loadBackupStatus();
  }

  Future<void> _loadBackupStatus() async {
    final time = await _backupRepository.getLastBackupTime();
    if (mounted) setState(() => _lastBackupTime = time);
  }

  /// Lets the operator choose where the backup file goes (Downloads, Drive, ...).
  Future<void> _createBackup() async {
    try {
      final json = await _backupRepository.createBackup();
      final saved = await FilePicker.saveFile(
        fileName: BackupRepository.backupFileName(),
        bytes: utf8.encode(json),
        mimeType: 'application/json',
      );
      if (saved == null) return;

      await _backupRepository.markBackupDone();
      await _loadBackupStatus();
      if (mounted) showAppSnack(context, 'Backup saved', kind: SnackKind.success);
    } catch (_) {
      if (mounted) showAppSnack(context, 'Couldn\'t create the backup', kind: SnackKind.error);
    }
  }

  Future<void> _restoreBackup() async {
    final file = await FilePicker.pickFile();
    if (file == null || !mounted) return;

    final confirmed = await confirmDialog(
      context,
      title: 'Restore from ${file.name}?',
      message: 'All orders on this device will be replaced with the orders in this backup. '
          'This can\'t be undone.',
      confirmLabel: 'Restore',
      destructive: true,
    );
    if (!confirmed) return;

    try {
      final json = utf8.decode(await file.readAsBytes());
      final count = await _backupRepository.restoreBackup(json);
      if (mounted) {
        showAppSnack(
          context,
          'Restored $count ${count == 1 ? "order" : "orders"}',
          kind: SnackKind.success,
        );
      }
    } on FormatException {
      if (mounted) {
        showAppSnack(context, 'That file isn\'t a Timbr backup', kind: SnackKind.error);
      }
    } catch (_) {
      if (mounted) {
        showAppSnack(context, 'Couldn\'t restore the backup. Your orders were not changed.',
            kind: SnackKind.error);
      }
    }
  }

  Future<void> _export() async {
    final orders = await OrderRepository().getAllOrders();
    if (mounted) ExportHelper.showExportOptionsModal(context, orders);
  }

  @override
  Widget build(BuildContext context) {
    final lastBackup = _lastBackupTime;

    return AppSection(
      title: 'Backup and export',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KeyValueRow(
            label: 'Last backup',
            value: lastBackup == null
                ? 'Never'
                : DateFormat('dd MMM yyyy, hh:mm a').format(lastBackup),
          ),
          const SizedBox(height: ShadTokens.spaceSm),
          OutlinedButton.icon(
            onPressed: _createBackup,
            icon: const Icon(Icons.save_alt),
            label: const Text('Create backup'),
          ),
          const SizedBox(height: ShadTokens.spaceSm),
          OutlinedButton.icon(
            onPressed: _restoreBackup,
            icon: const Icon(Icons.restore),
            label: const Text('Restore backup'),
          ),
          const SizedBox(height: ShadTokens.spaceSm),
          OutlinedButton.icon(
            onPressed: _export,
            icon: const Icon(Icons.file_download_outlined),
            label: const Text('Export orders (CSV or PDF)'),
          ),
        ],
      ),
    );
  }
}
