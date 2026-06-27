import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/providers/firebase_providers.dart';

class SupportTicket {
  final String id;
  final String userUid;
  final String userEmail;
  final String subject;
  final String description;
  final String status; // Open, In Progress, Closed
  final DateTime createdAt;

  const SupportTicket({
    required this.id,
    required this.userUid,
    required this.userEmail,
    required this.subject,
    required this.description,
    required this.status,
    required this.createdAt,
  });

  factory SupportTicket.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SupportTicket(
      id: doc.id,
      userUid: data['userUid'] as String? ?? '',
      userEmail: data['userEmail'] as String? ?? '',
      subject: data['subject'] as String? ?? '',
      description: data['description'] as String? ?? '',
      status: data['status'] as String? ?? 'Open',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

final supportTicketsProvider = StreamProvider<List<SupportTicket>>((ref) {
  final db = ref.watch(firestoreProvider);
  return db
      .collection('support_tickets')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => SupportTicket.fromDocument(doc)).toList());
});

Future<void> updateTicketStatus(
  FirebaseFirestore db, {
  required String ticketId,
  required String status,
}) async {
  await db.collection('support_tickets').doc(ticketId).update({
    'status': status,
    'updatedAt': FieldValue.serverTimestamp(),
  });
}
