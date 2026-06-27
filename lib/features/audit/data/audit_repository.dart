import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/providers/firebase_providers.dart';

class AuditLog {
  final String id;
  final String adminUid;
  final String adminEmail;
  final String action;
  final DateTime timestamp;

  const AuditLog({
    required this.id,
    required this.adminUid,
    required this.adminEmail,
    required this.action,
    required this.timestamp,
  });

  factory AuditLog.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AuditLog(
      id: doc.id,
      adminUid: data['adminUid'] as String? ?? 'unknown',
      adminEmail: data['adminEmail'] as String? ?? 'unknown',
      action: data['action'] as String? ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

final auditLogsProvider = StreamProvider<List<AuditLog>>((ref) {
  final db = ref.watch(firestoreProvider);
  return db
      .collection('audit_logs')
      .orderBy('timestamp', descending: true)
      .limit(100)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => AuditLog.fromDocument(doc)).toList());
});

Future<void> logAuditAction(
  FirebaseFirestore db, {
  required String adminUid,
  required String adminEmail,
  required String action,
}) async {
  await db.collection('audit_logs').add({
    'adminUid': adminUid,
    'adminEmail': adminEmail,
    'action': action,
    'timestamp': FieldValue.serverTimestamp(),
  });
}
