import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../data/moderation_repository.dart';
import '../../../core/providers/firebase_providers.dart';

class ChatModerationScreen extends ConsumerWidget {
  final String roomId;

  const ChatModerationScreen({super.key, required this.roomId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesAsync = ref.watch(roomMessagesProvider(roomId));
    final roomTitleAsync = ref.watch(roomTitleProvider(roomId));
    final db = ref.watch(firestoreProvider);

    final roomTitle = roomTitleAsync.asData?.value ?? roomId;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ──
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  color: Colors.white,
                  onPressed: () => context.go('/rooms'),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Chat Moderation',
                        style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 4),
                    Text(
                      'Room: $roomTitle',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                    ),
                  ],
                ),
                const Spacer(),
                messagesAsync.when(
                  data: (msgs) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      '${msgs.length} messages',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  loading: () => const SizedBox(),
                  error: (e, _) => const SizedBox(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // ── Messages list ──
            Expanded(
              child: messagesAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text('Error: $e',
                      style: const TextStyle(color: Colors.red)),
                ),
                data: (messages) => messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.chat_bubble_outline,
                                size: 64,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant),
                            const SizedBox(height: 16),
                            Text('No messages in this room',
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant)),
                          ],
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: const Color(0xFF353534)),
                        ),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: messages.length,
                          separatorBuilder: (_, i) => const Divider(
                              color: Color(0xFF353534), height: 1),
                          itemBuilder: (context, index) {
                            final msg = messages[index];
                            final ts =
                                (msg['timestamp'] as Timestamp?)?.toDate();
                            final handle =
                                msg['handle'] as String? ?? 'Anonymous';
                            final text = msg['text'] as String? ?? '';

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 8),
                              child: Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  // Avatar
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
                                    child: Text(
                                      handle.isNotEmpty
                                          ? handle[0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Content
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              handle,
                                              style: const TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold,
                                                  color: Colors.white),
                                            ),
                                            const SizedBox(width: 8),
                                            if (ts != null)
                                              Text(
                                                DateFormat('MMM dd, hh:mm a')
                                                    .format(ts),
                                                style: const TextStyle(
                                                    color:
                                                        Color(0xFF8F909E),
                                                    fontSize: 12),
                                              ),
                                            if (msg['tag'] != null) ...[
                                              const SizedBox(width: 8),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary
                                                      .withValues(alpha: 0.15),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  msg['tag'] as String,
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .secondary,
                                                    fontSize: 11,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          text,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 15),
                                        ),
                                        if ((msg['reactions'] as List?)
                                                ?.isNotEmpty ==
                                            true)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 8),
                                            child: Wrap(
                                              spacing: 6,
                                              children:
                                                  ((msg['reactions']
                                                              as List)
                                                          .toSet()
                                                          .toList())
                                                      .map((r) => Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        8,
                                                                    vertical:
                                                                        4),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: const Color(
                                                                  0xFF353534),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12),
                                                            ),
                                                            child: Text(
                                                                r.toString(),
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        14)),
                                                          ))
                                                      .toList(),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  // Actions
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        tooltip: 'Delete Message',
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
                                                  'Delete Message?'),
                                              content: Text(
                                                  '"$text"\n\nThis action cannot be undone.'),
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
                                            await deleteMessage(
                                                db,
                                                roomId,
                                                msg['id'] as String);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
