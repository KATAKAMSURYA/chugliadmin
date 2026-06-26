import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../rooms/data/rooms_repository.dart';

/// Moderation overview — lists all rooms so admin can pick one to moderate.
class ModerationOverviewScreen extends ConsumerStatefulWidget {
  const ModerationOverviewScreen({super.key});

  @override
  ConsumerState<ModerationOverviewScreen> createState() =>
      _ModerationOverviewScreenState();
}

class _ModerationOverviewScreenState
    extends ConsumerState<ModerationOverviewScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final roomsAsync = ref.watch(roomsStreamProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Chat Moderation',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Select a room to review and delete messages.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
            // Search
            Container(
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF353534)),
              ),
              child: TextField(
                onChanged: (v) => setState(() => _search = v.toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'Search rooms...',
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
            const SizedBox(height: 24),
            // Rooms grid
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
                    return _search.isEmpty || title.contains(_search);
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text('No rooms found.',
                          style: TextStyle(color: Color(0xFF8F909E))),
                    );
                  }

                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 2.8,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) {
                      final room = filtered[i];
                      final isActive = room['isActive'] == true;
                      final participants = room['participantCount'] as int? ?? 1;
                      final expiresAt =
                          (room['expiresAt'] as Timestamp?)?.toDate();

                      return InkWell(
                        onTap: () =>
                            context.go('/moderation/${room['id']}'),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF201F1F),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isActive
                                  ? Theme.of(context)
                                      .colorScheme
                                      .secondary
                                      .withValues(alpha: 0.3)
                                  : const Color(0xFF353534),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withValues(alpha: 0.1)
                                      : const Color(0xFF353534),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.chat_bubble_outline,
                                  size: 20,
                                  color: isActive
                                      ? Theme.of(context)
                                          .colorScheme
                                          .secondary
                                      : const Color(0xFF8F909E),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      room['title'] ?? 'Untitled',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$participants participants${expiresAt != null ? ' • ${DateFormat('MMM dd').format(expiresAt)}' : ''}',
                                      style: const TextStyle(
                                          color: Color(0xFF8F909E),
                                          fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withValues(alpha: 0.15)
                                      : const Color(0xFF353534),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  isActive ? 'LIVE' : 'CLOSED',
                                  style: TextStyle(
                                    color: isActive
                                        ? Theme.of(context)
                                            .colorScheme
                                            .secondary
                                        : const Color(0xFF8F909E),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
