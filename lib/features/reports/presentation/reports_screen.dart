import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../data/reports_repository.dart';
import '../../../core/providers/firebase_providers.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  String _filterStatus = 'Pending';
  Map<String, dynamic>? _selectedReport;

  @override
  Widget build(BuildContext context) {
    final reportsAsync = ref.watch(allReportsProvider);
    final db = ref.watch(firestoreProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Reports & Moderation',
                        style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 8),
                    Text(
                      'Manage reported content and user behavior across all rooms.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
                // Status filter tabs
                reportsAsync.when(
                  loading: () => const SizedBox(),
                  error: (e, _) => const SizedBox(),
                  data: (reports) {
                    final pending = reports.where((r) => r['status'] == 'Pending').length;
                    final resolved = reports.where((r) => r['status'] == 'Resolved').length;
                    final rejected = reports.where((r) => r['status'] == 'Rejected').length;
                    return Row(
                      children: [
                        _FilterBtn(
                          label: 'Pending ($pending)',
                          isSelected: _filterStatus == 'Pending',
                          onTap: () => setState(() => _filterStatus = 'Pending'),
                        ),
                        const SizedBox(width: 16),
                        _FilterBtn(
                          label: 'Resolved ($resolved)',
                          isSelected: _filterStatus == 'Resolved',
                          onTap: () => setState(() => _filterStatus = 'Resolved'),
                        ),
                        const SizedBox(width: 16),
                        _FilterBtn(
                          label: 'Rejected ($rejected)',
                          isSelected: _filterStatus == 'Rejected',
                          onTap: () => setState(() => _filterStatus = 'Rejected'),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: reportsAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text('Error: $e',
                      style: const TextStyle(color: Colors.red)),
                ),
                data: (allReports) {
                  final filtered = allReports
                      .where((r) => r['status'] == _filterStatus)
                      .toList();

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Left list ──
                      Expanded(
                        flex: 2,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardTheme.color,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF353534)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(24),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Recent Reports',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium),
                                    Text(
                                      '${filtered.length} reports',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: filtered.isEmpty
                                    ? const Center(
                                        child: Text('No reports found',
                                            style: TextStyle(
                                                color: Color(0xFF8F909E))),
                                      )
                                    : ListView.separated(
                                        itemCount: filtered.length,
                                        separatorBuilder: (_, i) =>
                                            const Divider(
                                                color: Color(0xFF353534),
                                                height: 1),
                                        itemBuilder: (context, index) {
                                          final report = filtered[index];
                                          final isSelected =
                                              _selectedReport?['id'] ==
                                                  report['id'];
                                          final ts =
                                              (report['timestamp'] as Timestamp?)
                                                  ?.toDate();

                                          return InkWell(
                                            onTap: () => setState(
                                                () => _selectedReport = report),
                                            child: Container(
                                              color: isSelected
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .primary
                                                      .withValues(alpha: 0.08)
                                                  : Colors.transparent,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 24,
                                                      vertical: 16),
                                              child: Row(
                                                children: [
                                                  CircleAvatar(
                                                    backgroundColor:
                                                        Theme.of(context)
                                                            .colorScheme
                                                            .primaryContainer,
                                                    child: Text(
                                                      (report['reportedHandle']
                                                                  as String? ??
                                                              '?')
                                                          .substring(0, 1)
                                                          .toUpperCase(),
                                                      style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 12),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          report['reportedHandle'] ??
                                                              'Unknown',
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                        const SizedBox(
                                                            height: 2),
                                                        Text(
                                                          '"${report['messageText'] ?? ''}"',
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: const TextStyle(
                                                              color: Color(
                                                                  0xFF8F909E),
                                                              fontSize: 12),
                                                        ),
                                                        Text(
                                                          report['roomTitle'] ??
                                                              '',
                                                          style: const TextStyle(
                                                              color: Color(
                                                                  0xFF8F909E),
                                                              fontSize: 11),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      _ReasonChip(
                                                          reason: report[
                                                                  'reason'] ??
                                                              'Unknown'),
                                                      if (ts != null)
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(top: 4),
                                                          child: Text(
                                                            DateFormat(
                                                                    'MMM dd')
                                                                .format(ts),
                                                            style: const TextStyle(
                                                                color: Color(
                                                                    0xFF8F909E),
                                                                fontSize: 11),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      // ── Right detail pane ──
                      Expanded(
                        flex: 1,
                        child: _selectedReport == null
                            ? Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardTheme.color,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: const Color(0xFF353534)),
                                ),
                                child: const Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.remove_red_eye_outlined,
                                          size: 48, color: Color(0xFF8F909E)),
                                      SizedBox(height: 16),
                                      Text('Select a Report',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold)),
                                      SizedBox(height: 8),
                                      Text(
                                        'Click on any item in the list to\nview details and take action.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Color(0xFF8F909E)),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardTheme.color,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: const Color(0xFF353534)),
                                ),
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text('Report Details',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium),
                                    const SizedBox(height: 24),
                                    _DetailRow(
                                        label: 'REPORTED USER',
                                        value: _selectedReport!['reportedHandle'] ?? '—'),
                                    _DetailRow(
                                        label: 'REASON',
                                        value: _selectedReport!['reason'] ?? '—'),
                                    _DetailRow(
                                        label: 'ROOM',
                                        value: _selectedReport!['roomTitle'] ?? '—'),
                                    _DetailRow(
                                        label: 'MESSAGE',
                                        value: _selectedReport!['messageText'] ?? '—'),
                                    _DetailRow(
                                        label: 'STATUS',
                                        value: _selectedReport!['status'] ?? '—'),
                                    const Spacer(),
                                    if (_selectedReport!['status'] == 'Pending') ...[
                                      ElevatedButton(
                                        onPressed: () async {
                                          await updateReportStatus(db,
                                            roomId: _selectedReport!['roomId'],
                                            reportId: _selectedReport!['id'],
                                            status: 'Resolved',
                                          );
                                          setState(() => _selectedReport = null);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Theme.of(context).colorScheme.secondary,
                                          foregroundColor: Colors.black,
                                        ),
                                        child: const Text('Mark as Resolved'),
                                      ),
                                      const SizedBox(height: 12),
                                      OutlinedButton(
                                        onPressed: () async {
                                          await updateReportStatus(db,
                                            roomId: _selectedReport!['roomId'],
                                            reportId: _selectedReport!['id'],
                                            status: 'Rejected',
                                          );
                                          setState(() => _selectedReport = null);
                                        },
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor:
                                              Theme.of(context).colorScheme.error,
                                          side: BorderSide(
                                            color: Theme.of(context).colorScheme.error,
                                          ),
                                        ),
                                        child: const Text('Reject Report'),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterBtn extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterBtn({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF353534)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Color(0xFF8F909E),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 14)),
          const SizedBox(height: 8),
          const Divider(color: Color(0xFF353534), height: 1),
        ],
      ),
    );
  }
}

class _ReasonChip extends StatelessWidget {
  final String reason;

  const _ReasonChip({required this.reason});

  @override
  Widget build(BuildContext context) {
    Color color = Theme.of(context).colorScheme.error;
    if (reason.toLowerCase().contains('spam')) {
      color = Theme.of(context).colorScheme.secondary;
    } else if (reason.toLowerCase().contains('security')) {
      color = Theme.of(context).colorScheme.primaryContainer;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(reason,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
