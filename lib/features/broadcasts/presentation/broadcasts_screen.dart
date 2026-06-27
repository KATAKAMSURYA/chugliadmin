import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../data/broadcasts_repository.dart';
import '../../audit/data/audit_repository.dart';
import '../../../core/providers/firebase_providers.dart';

class BroadcastsScreen extends ConsumerStatefulWidget {
  const BroadcastsScreen({super.key});

  @override
  ConsumerState<BroadcastsScreen> createState() => _BroadcastsScreenState();
}

class _BroadcastsScreenState extends ConsumerState<BroadcastsScreen> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  String _target = 'all';
  bool _isSending = false;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendBroadcast() async {
    if (_titleController.text.trim().isEmpty ||
        _messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all fields')),
      );
      return;
    }

    setState(() => _isSending = true);
    final user = FirebaseAuth.instance.currentUser;

    try {
      final db = ref.read(firestoreProvider);
      
      await sendBroadcast(
        db,
        title: _titleController.text.trim(),
        message: _messageController.text.trim(),
        target: _target,
        createdBy: user?.email ?? user?.uid ?? 'Admin',
      );
      
      await logAuditAction(
        db,
        adminUid: user?.uid ?? 'unknown',
        adminEmail: user?.email ?? 'Unknown Admin',
        action: 'Sent broadcast: "${_titleController.text.trim()}" to $_target',
      );

      _titleController.clear();
      _messageController.clear();
      setState(() => _target = 'all');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Broadcast sent successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send broadcast: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final broadcastsAsync = ref.watch(broadcastsProvider);

    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Side: Create Broadcast Form
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('New Broadcast',
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Send a push notification or in-app announcement to users.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF131313),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF353534)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Title',
                            hintText: 'e.g., Server Maintenance',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          controller: _messageController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Message',
                            hintText: 'Write your announcement here...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 24),
                        DropdownButtonFormField<String>(
                          initialValue: _target,
                          decoration: const InputDecoration(
                            labelText: 'Target Audience',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                                value: 'all', child: Text('All Users')),
                            DropdownMenuItem(
                                value: 'active_rooms', child: Text('Active Rooms Only')),
                          ],
                          onChanged: (v) {
                            if (v != null) setState(() => _target = v);
                          },
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          onPressed: _isSending ? null : _sendBroadcast,
                          icon: _isSending
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.send),
                          label: Text(_isSending ? 'Sending...' : 'Send Broadcast'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Right Side: Broadcast History
          Expanded(
            flex: 3,
            child: Container(
              decoration: const BoxDecoration(
                border: Border(left: BorderSide(color: Color(0xFF353534))),
                color: Color(0xFF131313),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text('Broadcast History',
                        style: Theme.of(context).textTheme.titleLarge),
                  ),
                  Expanded(
                    child: broadcastsAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text('Error: $e')),
                      data: (broadcasts) {
                        if (broadcasts.isEmpty) {
                          return const Center(child: Text('No broadcasts sent yet.'));
                        }
                        return ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          itemCount: broadcasts.length,
                          separatorBuilder: (_, _) => const Divider(color: Color(0xFF353534)),
                          itemBuilder: (context, index) {
                            final b = broadcasts[index];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(b.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(b.message),
                                  const SizedBox(height: 8),
                                  Text(
                                    'To: ${b.target} • By: ${b.createdBy} • ${DateFormat.yMd().add_jm().format(b.createdAt)}',
                                    style: const TextStyle(color: Color(0xFF8F909E), fontSize: 12),
                                  ),
                                ],
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
          ),
        ],
      ),
    );
  }
}
