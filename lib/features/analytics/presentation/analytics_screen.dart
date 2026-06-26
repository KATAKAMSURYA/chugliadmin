import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../data/analytics_repository.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryAsync = ref.watch(roomCategoryStatsProvider);
    final statusAsync = ref.watch(roomStatusStatsProvider);
    final reportsAsync = ref.watch(reportStatusStatsProvider);
    final usersAsync = ref.watch(totalUsersCountProvider);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ──
            Text('Analytics', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Live data from your Chugli Firebase backend.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 32),

            // ── Top summary cards ──
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    label: 'TOTAL USERS',
                    valueAsync: usersAsync,
                    icon: Icons.people_outline,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: statusAsync.when(
                    loading: () => _loadingCard(),
                    error: (e, _) => _errorCard(e),
                    data: (status) => _SummaryCard(
                      label: 'ACTIVE ROOMS',
                      value: status['Active']?.toString() ?? '0',
                      icon: Icons.meeting_room_outlined,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: reportsAsync.when(
                    loading: () => _loadingCard(),
                    error: (e, _) => _errorCard(e),
                    data: (reports) => _SummaryCard(
                      label: 'PENDING REPORTS',
                      value: reports['Pending']?.toString() ?? '0',
                      icon: Icons.report_problem_outlined,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: reportsAsync.when(
                    loading: () => _loadingCard(),
                    error: (e, _) => _errorCard(e),
                    data: (reports) => _SummaryCard(
                      label: 'RESOLVED REPORTS',
                      value: reports['Resolved']?.toString() ?? '0',
                      icon: Icons.check_circle_outline,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // ── Charts Row ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Room categories pie chart
                Expanded(
                  child: _ChartCard(
                    title: 'Rooms by Category',
                    subtitle: 'Distribution of all rooms',
                    child: categoryAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(
                        child: Text('Error: $e',
                            style: const TextStyle(color: Colors.red)),
                      ),
                      data: (categories) {
                        if (categories.isEmpty) {
                          return const Center(
                              child: Text('No rooms yet',
                                  style:
                                      TextStyle(color: Color(0xFF8F909E))));
                        }
                        final colors = [
                          const Color(0xFFBAC3FF),
                          const Color(0xFF50DAD1),
                          const Color(0xFFC0C1FF),
                          const Color(0xFF72F7ED),
                          const Color(0xFFFFB4AB),
                          const Color(0xFF8F909E),
                        ];
                        final entries = categories.entries.toList();
                        final total =
                            entries.fold<int>(0, (s, e) => s + e.value);
                        return Column(
                          children: [
                            SizedBox(
                              height: 200,
                              child: PieChart(
                                PieChartData(
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 50,
                                  sections: List.generate(entries.length,
                                      (i) {
                                    final pct =
                                        entries[i].value / total * 100;
                                    return PieChartSectionData(
                                      color: colors[i % colors.length],
                                      value: entries[i].value.toDouble(),
                                      title: '${pct.toStringAsFixed(0)}%',
                                      radius: 60,
                                      titleStyle: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    );
                                  }),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 16,
                              runSpacing: 8,
                              children: List.generate(entries.length, (i) {
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: colors[i % colors.length],
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${entries[i].key} (${entries[i].value})',
                                      style: const TextStyle(
                                          color: Color(0xFF8F909E),
                                          fontSize: 12),
                                    ),
                                  ],
                                );
                              }),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 24),

                // Reports status bar chart
                Expanded(
                  child: _ChartCard(
                    title: 'Reports by Status',
                    subtitle: 'Overview of all report outcomes',
                    child: reportsAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(
                        child: Text('Error: $e',
                            style: const TextStyle(color: Colors.red)),
                      ),
                      data: (reports) {
                        final statuses = [
                          'Pending',
                          'Resolved',
                          'Rejected'
                        ];
                        final colors = [
                          Theme.of(context).colorScheme.error,
                          Theme.of(context).colorScheme.secondary,
                          Theme.of(context).colorScheme.onSurfaceVariant,
                        ];
                        final max = statuses.fold<int>(
                            1,
                            (m, s) =>
                                (reports[s] ?? 0) > m
                                    ? (reports[s] ?? 0)
                                    : m);

                        return Column(
                          children: [
                            SizedBox(
                              height: 200,
                              child: BarChart(
                                BarChartData(
                                  maxY: (max * 1.3).toDouble(),
                                  gridData: const FlGridData(show: false),
                                  borderData:
                                      FlBorderData(show: false),
                                  titlesData: FlTitlesData(
                                    show: true,
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          final idx = value.toInt();
                                          if (idx < 0 ||
                                              idx >= statuses.length) {
                                            return const SizedBox();
                                          }
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                top: 8),
                                            child: Text(
                                              statuses[idx],
                                              style: const TextStyle(
                                                  color: Color(0xFF8F909E),
                                                  fontSize: 11),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    leftTitles: const AxisTitles(
                                      sideTitles:
                                          SideTitles(showTitles: false),
                                    ),
                                    topTitles: const AxisTitles(
                                      sideTitles:
                                          SideTitles(showTitles: false),
                                    ),
                                    rightTitles: const AxisTitles(
                                      sideTitles:
                                          SideTitles(showTitles: false),
                                    ),
                                  ),
                                  barGroups: List.generate(
                                    statuses.length,
                                    (i) => BarChartGroupData(
                                      x: i,
                                      barRods: [
                                        BarChartRodData(
                                          toY: (reports[statuses[i]] ?? 0)
                                              .toDouble(),
                                          color: colors[i],
                                          width: 40,
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                  top: Radius.circular(4)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceAround,
                              children: List.generate(statuses.length, (i) {
                                return Column(
                                  children: [
                                    Text(
                                      '${reports[statuses[i]] ?? 0}',
                                      style: TextStyle(
                                          color: colors[i],
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),
                                    ),
                                    Text(statuses[i],
                                        style: const TextStyle(
                                            color: Color(0xFF8F909E),
                                            fontSize: 12)),
                                  ],
                                );
                              }),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Room status row ──
            _ChartCard(
              title: 'Room Status Overview',
              subtitle: 'Active vs expired rooms',
              child: statusAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text('Error: $e',
                      style: const TextStyle(color: Colors.red)),
                ),
                data: (status) {
                  final active = status['Active'] ?? 0;
                  final expired = status['Expired'] ?? 0;
                  final total = active + expired;
                  if (total == 0) {
                    return const Center(
                        child: Text('No rooms yet',
                            style: TextStyle(color: Color(0xFF8F909E))));
                  }
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Active Rooms',
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary)),
                                    Text('$active / $total',
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: total > 0
                                        ? active / total
                                        : 0,
                                    minHeight: 12,
                                    backgroundColor: const Color(0xFF353534),
                                    valueColor: AlwaysStoppedAnimation(
                                        Theme.of(context)
                                            .colorScheme
                                            .secondary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 32),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Expired Rooms',
                                        style: const TextStyle(
                                            color: Color(0xFF8F909E))),
                                    Text('$expired / $total',
                                        style: const TextStyle(
                                            color: Color(0xFF8F909E),
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: total > 0
                                        ? expired / total
                                        : 0,
                                    minHeight: 12,
                                    backgroundColor: const Color(0xFF353534),
                                    valueColor:
                                        const AlwaysStoppedAnimation(
                                            Color(0xFF353534)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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

  Widget _loadingCard() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: const Color(0xFF201F1F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF353534)),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _errorCard(Object e) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: const Color(0xFF201F1F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF353534)),
      ),
      child: Center(
        child: Text('Error: $e', style: const TextStyle(color: Colors.red)),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String? value;
  final AsyncValue<int>? valueAsync;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.label,
    this.value,
    this.valueAsync,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final displayValue = value ??
        valueAsync?.when(
          data: (v) => v.toString(),
          loading: () => '...',
          error: (e, _) => '—',
        ) ??
        '—';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF201F1F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF353534)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 16),
          Text(
            displayValue,
            style: TextStyle(
                color: color, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  color: Color(0xFF8F909E),
                  fontSize: 11,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _ChartCard(
      {required this.title, required this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF201F1F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF353534)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(subtitle,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  )),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }
}
