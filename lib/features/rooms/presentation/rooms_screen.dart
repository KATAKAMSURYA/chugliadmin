import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../data/rooms_repository.dart';
import '../../../core/providers/firebase_providers.dart';

class RoomsScreen extends ConsumerStatefulWidget {
  const RoomsScreen({super.key});

  @override
  ConsumerState<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends ConsumerState<RoomsScreen> {
  String _filterStatus = 'All Rooms';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final roomsAsync = ref.watch(roomsStreamProvider);
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
                    Text('Room Management',
                        style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 8),
                    Text(
                      'Monitor and manage all active community streaming spaces.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF353534)),
                  ),
                  child: Row(
                    children: ['All Rooms', 'Active', 'Inactive']
                        .map((status) => GestureDetector(
                              onTap: () =>
                                  setState(() => _filterStatus = status),
                              child: _TabBtn(
                                label: status,
                                isSelected: _filterStatus == status,
                              ),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF353534)),
                    ),
                    child: TextField(
                      onChanged: (v) =>
                          setState(() => _searchQuery = v.toLowerCase()),
                      decoration: InputDecoration(
                        hintText: 'Search rooms by title or ID...',
                        prefixIcon: const Icon(Icons.search,
                            size: 20, color: Color(0xFF8F909E)),
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
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Data Table
            Expanded(
              child: roomsAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text('Error: $e',
                      style: const TextStyle(color: Colors.red)),
                ),
                data: (rooms) {
                  final filtered = rooms.where((r) {
                    final title =
                        (r['title'] as String? ?? '').toLowerCase();
                    final id = (r['id'] as String? ?? '').toLowerCase();
                    final isActive = r['isActive'] == true;

                    final matchesSearch = _searchQuery.isEmpty ||
                        title.contains(_searchQuery) ||
                        id.contains(_searchQuery);

                    final matchesFilter =
                        _filterStatus == 'All Rooms' ||
                            (_filterStatus == 'Active' && isActive) ||
                            (_filterStatus == 'Inactive' && !isActive);

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
                                  headingTextStyle: Theme.of(context)
                                      .textTheme
                                      .labelLarge
                                      ?.copyWith(color: const Color(0xFF8F909E)),
                                  dataTextStyle:
                                      Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                              child: DataTable(
                                horizontalMargin: 24,
                                columnSpacing: 24,
                                columns: const [
                                  DataColumn(label: Text('ROOM NAME')),
                                  DataColumn(label: Text('CATEGORY')),
                                  DataColumn(label: Text('PARTICIPANTS')),
                                  DataColumn(label: Text('STATUS')),
                                  DataColumn(label: Text('EXPIRES')),
                                  DataColumn(
                                    label: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text('ACTIONS'),
                                    ),
                                  ),
                                ],
                                rows: filtered.map((room) {
                                  final isActive = room['isActive'] == true;
                                  final expiresAt =
                                      (room['expiresAt'] as Timestamp?)
                                          ?.toDate();
                                  final participants =
                                      room['participantCount'] as int? ?? 1;

                                  return DataRow(cells: [
                                    DataCell(
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            room['title'] ?? 'Untitled',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w500),
                                          ),
                                          Text(
                                            'ID: ${room['id']}',
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color: Color(0xFF8F909E)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF353534),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: Text(
                                          room['category'] ?? '—',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    DataCell(Text('$participants')),
                                    DataCell(
                                      _StatusChip(isActive: isActive),
                                    ),
                                    DataCell(Text(
                                      expiresAt != null
                                          ? DateFormat('MMM dd, HH:mm')
                                              .format(expiresAt)
                                          : '—',
                                      style: const TextStyle(fontSize: 12),
                                    )),
                                    DataCell(
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // View messages/moderate
                                            IconButton(
                                              tooltip: 'Moderate Chat',
                                              icon: const Icon(
                                                  Icons.chat_outlined,
                                                  size: 20),
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              onPressed: () => context.go(
                                                  '/moderation/${room['id']}'),
                                            ),
                                            // Delete room
                                            IconButton(
                                              tooltip: 'Delete Room',
                                              icon: const Icon(
                                                  Icons.delete_outline,
                                                  size: 20),
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .error,
                                              onPressed: () async {
                                                final confirm =
                                                    await showDialog<bool>(
                                                  context: context,
                                                  builder: (ctx) => AlertDialog(
                                                    backgroundColor:
                                                        const Color(0xFF201F1F),
                                                    title: const Text(
                                                        'Delete Room?'),
                                                    content: Text(
                                                        'Are you sure you want to delete "${room['title']}"? This cannot be undone.'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                ctx, false),
                                                        child: const Text(
                                                            'Cancel'),
                                                      ),
                                                      ElevatedButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .error,
                                                          foregroundColor:
                                                              Colors.white,
                                                        ),
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                ctx, true),
                                                        child: const Text(
                                                            'Delete'),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                                if (confirm == true) {
                                                  await deleteRoom(
                                                      db, room['id']);
                                                }
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
                            'Showing ${filtered.length} of ${rooms.length} rooms',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF353534) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected
              ? Colors.white
              : Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool isActive;

  const _StatusChip({required this.isActive});

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? Theme.of(context).colorScheme.secondary
        : const Color(0xFF8F909E);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? color.withValues(alpha: 0.15) : const Color(0xFF353534),
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
          Text(
            isActive ? 'Open' : 'Closed',
            style: TextStyle(
              color: isActive ? color : Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
