import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../data/audit_repository.dart';

class AuditLogsScreen extends ConsumerWidget {
  const AuditLogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(auditLogsProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Audit Logs', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'A chronological record of actions taken by admins in the dashboard.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF201F1F),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF353534)),
                ),
                child: logsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  data: (logs) {
                    if (logs.isEmpty) {
                      return const Center(child: Text('No audit logs available.'));
                    }
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Timestamp')),
                            DataColumn(label: Text('Admin UID')),
                            DataColumn(label: Text('Admin Email')),
                            DataColumn(label: Text('Action')),
                          ],
                          rows: logs.map((log) {
                            return DataRow(
                              cells: [
                                DataCell(Text(DateFormat('yyyy-MM-dd HH:mm').format(log.timestamp))),
                                DataCell(Text(log.adminUid)),
                                DataCell(Text(log.adminEmail)),
                                DataCell(Text(log.action)),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
