import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/support_repository.dart';
import '../../audit/data/audit_repository.dart';
import '../../../core/providers/firebase_providers.dart';

class SupportScreen extends ConsumerWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketsAsync = ref.watch(supportTicketsProvider);
    final db = ref.watch(firestoreProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Support Tickets', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'View and manage support requests from users.',
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
                child: ticketsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  data: (tickets) {
                    if (tickets.isEmpty) {
                      return const Center(child: Text('No support tickets yet.'));
                    }
                    return ListView.separated(
                      itemCount: tickets.length,
                      separatorBuilder: (context, index) => const Divider(color: Color(0xFF353534), height: 1),
                      itemBuilder: (context, index) {
                        final ticket = tickets[index];
                        return ExpansionTile(
                          title: Text(ticket.subject, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            'From: ${ticket.userEmail} • ${DateFormat('MMM dd, yyyy HH:mm').format(ticket.createdAt)}',
                            style: const TextStyle(color: Color(0xFF8F909E), fontSize: 12),
                          ),
                          trailing: _StatusChip(status: ticket.status),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(ticket.description, style: const TextStyle(color: Colors.white70)),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if (ticket.status != 'Closed')
                                        ElevatedButton(
                                          onPressed: () async {
                                            await updateTicketStatus(db, ticketId: ticket.id, status: 'Closed');
                                            final user = FirebaseAuth.instance.currentUser;
                                            if (user != null) {
                                              await logAuditAction(
                                                db,
                                                adminUid: user.uid,
                                                adminEmail: user.email ?? 'Unknown',
                                                action: 'Closed support ticket: ${ticket.id}',
                                              );
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                          child: const Text('Mark as Closed', style: TextStyle(color: Colors.white)),
                                        ),
                                      const SizedBox(width: 8),
                                      if (ticket.status == 'Open')
                                        OutlinedButton(
                                          onPressed: () async {
                                            await updateTicketStatus(db, ticketId: ticket.id, status: 'In Progress');
                                            final user = FirebaseAuth.instance.currentUser;
                                            if (user != null) {
                                              await logAuditAction(
                                                db,
                                                adminUid: user.uid,
                                                adminEmail: user.email ?? 'Unknown',
                                                action: 'Started work on support ticket: ${ticket.id}',
                                              );
                                            }
                                          },
                                          child: const Text('Mark In Progress'),
                                        ),
                                    ],
                                  )
                                ],
                              ),
                            )
                          ],
                        );
                      },
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

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    if (status == 'Open') {
      color = Colors.orange;
    } else if (status == 'In Progress') {
      color = Colors.blue;
    } else {
      color = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
