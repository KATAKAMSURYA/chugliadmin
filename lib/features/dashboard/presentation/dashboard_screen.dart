import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../data/dashboard_repository.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final recentMsgsAsync = ref.watch(recentMessagesProvider);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Stats Grid ──
            statsAsync.when(
              loading: () => const SizedBox(
                height: 160,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Center(
                child: Text('Error loading stats: $e',
                    style: const TextStyle(color: Colors.red)),
              ),
              data: (stats) => GridView.count(
                crossAxisCount: 5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.2,
                children: [
                  _StatCard(
                    title: 'Total Users',
                    value: NumberFormat.compact().format(stats.totalUsers),
                    icon: Icons.people_outline,
                  ),
                  _StatCard(
                    title: 'Total Rooms',
                    value: stats.totalRooms.toString(),
                    icon: Icons.meeting_room_outlined,
                  ),
                  _StatCard(
                    title: 'Active Rooms',
                    value: stats.activeRooms.toString(),
                    icon: Icons.bolt_outlined,
                    trend: 'LIVE',
                  ),
                  _StatCard(
                    title: 'Pending Reports',
                    value: stats.pendingReports.toString(),
                    icon: Icons.report_problem_outlined,
                    isCritical: stats.pendingReports > 0,
                  ),
                  _StatCard(
                    title: 'Inactive Rooms',
                    value: (stats.totalRooms - stats.activeRooms).toString(),
                    icon: Icons.history_outlined,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // ── Recent Activity ──
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF353534)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Recent Moderation Activity',
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 4),
                          Text(
                            'Real-time system actions and user messages',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                      OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFF353534)),
                        ),
                        child: const Text('View Full Logs'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  recentMsgsAsync.when(
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (e, _) => Center(
                      child: Text('Error: $e',
                          style: const TextStyle(color: Colors.red)),
                    ),
                    data: (messages) => messages.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32),
                              child: Text('No recent messages',
                                  style: TextStyle(color: Color(0xFF8F909E))),
                            ),
                          )
                        : Column(
                            children: messages.map((msg) {
                              final ts = (msg['timestamp'] as Timestamp?)?.toDate();
                              final timeAgo = ts != null
                                  ? _timeAgo(ts)
                                  : 'Unknown time';
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primaryContainer
                                            .withValues(alpha: 0.3),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.chat_bubble_outline,
                                          size: 16, color: Color(0xFFBAC3FF)),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                              style: const TextStyle(
                                                  fontSize: 14, color: Colors.white),
                                              children: [
                                                TextSpan(
                                                  text: msg['handle'] ?? 'Anonymous',
                                                  style: const TextStyle(
                                                      fontWeight: FontWeight.bold),
                                                ),
                                                const TextSpan(text: ' said in '),
                                                TextSpan(
                                                  text: msg['roomTitle'],
                                                  style: const TextStyle(
                                                    color: Color(0xFF50DAD1),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '"${msg['text'] ?? ''}"',
                                            style: const TextStyle(
                                              color: Color(0xFF8F909E),
                                              fontSize: 13,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      timeAgo,
                                      style: const TextStyle(
                                          color: Color(0xFF8F909E), fontSize: 12),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
    if (diff.inHours < 24) return '${diff.inHours} hrs ago';
    return '${diff.inDays} days ago';
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final String? trend;
  final bool isCritical;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    this.trend,
    this.isCritical = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF353534)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                color: isCritical
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              if (trend != null || isCritical)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCritical
                        ? Theme.of(context).colorScheme.error.withValues(alpha: 0.15)
                        : Theme.of(context).colorScheme.secondary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isCritical ? 'CRITICAL' : trend!,
                    style: TextStyle(
                      color: isCritical
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.secondary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isCritical
                          ? Theme.of(context).colorScheme.error
                          : Colors.white,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
