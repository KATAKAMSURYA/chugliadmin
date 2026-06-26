import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../data/users_repository.dart';
import '../../../core/providers/firebase_providers.dart';

class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  String _filterStatus = 'All';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(usersStreamProvider);
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
                    Text('User Management',
                        style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 8),
                    Text(
                      'Manage application access, monitor status, and handle user moderations.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
                // Filter Tabs
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF353534)),
                  ),
                  child: Row(
                    children: ['All', 'Active', 'Suspended', 'Banned']
                        .map((status) => GestureDetector(
                              onTap: () => setState(() => _filterStatus = status),
                              child: _TabBtn(
                                  label: status,
                                  isSelected: _filterStatus == status),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Search Bar
            Container(
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF353534)),
              ),
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'Search users by handle or UID...',
                  prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF8F909E)),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintStyle: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: const Color(0xFF8F909E)),
                ),
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
            const SizedBox(height: 16),
            // Data Table
            Expanded(
              child: usersAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text('Error: $e',
                      style: const TextStyle(color: Colors.red)),
                ),
                data: (users) {
                  // Filter
                  final filtered = users.where((u) {
                    final isBanned = u['isBanned'] == true;
                    final isSuspended = u['isSuspended'] == true;
                    final handle =
                        (u['handle'] as String? ?? '').toLowerCase();
                    final uid = (u['uid'] as String? ?? '').toLowerCase();

                    final matchesSearch = _searchQuery.isEmpty ||
                        handle.contains(_searchQuery) ||
                        uid.contains(_searchQuery);

                    final matchesFilter = _filterStatus == 'All' ||
                        (_filterStatus == 'Banned' && isBanned) ||
                        (_filterStatus == 'Suspended' && isSuspended) ||
                        (_filterStatus == 'Active' && !isBanned && !isSuspended);

                    return matchesSearch && matchesFilter;
                  }).toList();

                  return Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF353534)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                dividerColor: const Color(0xFF353534),
                                dataTableTheme: DataTableThemeData(
                                  headingTextStyle:
                                      Theme.of(context).textTheme.labelLarge?.copyWith(
                                            color: const Color(0xFF8F909E),
                                          ),
                                  dataTextStyle:
                                      Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                              child: DataTable(
                                horizontalMargin: 24,
                                columnSpacing: 24,
                                columns: const [
                                  DataColumn(label: Text('USER')),
                                  DataColumn(label: Text('HANDLE')),
                                  DataColumn(label: Text('STATUS')),
                                  DataColumn(label: Text('LAST UPDATED')),
                                  DataColumn(
                                    label: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text('ACTIONS'),
                                    ),
                                  ),
                                ],
                                rows: filtered.map((user) {
                                  final uid = user['uid'] as String;
                                  final handle = user['handle'] as String? ?? 'Anonymous';
                                  final isBanned = user['isBanned'] == true;
                                  final isSuspended = user['isSuspended'] == true;
                                  final updatedAt =
                                      (user['updatedAt'] as dynamic)?.toDate
                                          ?.call() as DateTime?;

                                  return DataRow(cells: [
                                    DataCell(
                                      Row(children: [
                                        const CircleAvatar(
                                          radius: 16,
                                          backgroundColor: Color(0xFF353534),
                                          child: Icon(Icons.person,
                                              size: 16, color: Colors.white),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          uid.length > 10
                                              ? '${uid.substring(0, 10)}...'
                                              : uid,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF8F909E)),
                                        ),
                                      ]),
                                    ),
                                    DataCell(Text(handle)),
                                    DataCell(_StatusChip(
                                        isBanned: isBanned,
                                        isSuspended: isSuspended)),
                                    DataCell(Text(
                                      updatedAt != null
                                          ? DateFormat('MMM dd, yyyy')
                                              .format(updatedAt)
                                          : '—',
                                    )),
                                    DataCell(
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // Suspend/Unsuspend
                                            IconButton(
                                              tooltip: isSuspended
                                                  ? 'Unsuspend'
                                                  : 'Suspend',
                                              icon: Icon(
                                                isSuspended
                                                    ? Icons.play_circle_outline
                                                    : Icons.pause_circle_outline,
                                                size: 20,
                                              ),
                                              color: isSuspended
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .secondary
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                              onPressed: () async {
                                                await updateUserStatus(db, uid,
                                                    {'isSuspended': !isSuspended});
                                              },
                                            ),
                                            // Ban/Unban
                                            IconButton(
                                              tooltip: isBanned ? 'Unban' : 'Ban',
                                              icon: Icon(
                                                isBanned
                                                    ? Icons.check_circle_outline
                                                    : Icons.gavel_outlined,
                                                size: 20,
                                              ),
                                              color: isBanned
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .secondary
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .error,
                                              onPressed: () async {
                                                await updateUserStatus(
                                                    db, uid, {'isBanned': !isBanned});
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ]);
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16),
                          decoration: const BoxDecoration(
                            border: Border(
                                top: BorderSide(color: Color(0xFF353534))),
                          ),
                          child: Text(
                            'Showing ${filtered.length} of ${users.length} users',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                        ),
                      ],
                    ),
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

class _TabBtn extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _TabBtn({required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).colorScheme.primaryContainer
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected
              ? Colors.white
              : Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool isBanned;
  final bool isSuspended;

  const _StatusChip({required this.isBanned, required this.isSuspended});

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String label;
    if (isBanned) {
      color = Theme.of(context).colorScheme.error;
      label = 'Banned';
    } else if (isSuspended) {
      color = Theme.of(context).colorScheme.primary;
      label = 'Suspended';
    } else {
      color = Theme.of(context).colorScheme.secondary;
      label = 'Active';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 6,
              height: 6,
              decoration:
                  BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
