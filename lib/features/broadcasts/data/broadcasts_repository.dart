import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/providers/firebase_providers.dart';

// ── Broadcast model ───────────────────────────────────────────────────
class AppBroadcast {
  final String id;
  final String title;
  final String message;
  final String target; // "all", "active_rooms", etc.
  final DateTime createdAt;
  final String createdBy;

  const AppBroadcast({
    required this.id,
    required this.title,
    required this.message,
    required this.target,
    required this.createdAt,
    required this.createdBy,
  });

  factory AppBroadcast.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppBroadcast(
      id: doc.id,
      title: data['title'] as String? ?? '',
      message: data['message'] as String? ?? '',
      target: data['target'] as String? ?? 'all',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: data['createdBy'] as String? ?? 'System',
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'message': message,
        'target': target,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': createdBy,
      };
}

// ── Broadcasts provider ───────────────────────────────────────────────
final broadcastsProvider = StreamProvider<List<AppBroadcast>>((ref) {
  final db = ref.watch(firestoreProvider);
  return db
      .collection('broadcasts')
      .orderBy('createdAt', descending: true)
      .limit(50)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => AppBroadcast.fromDocument(doc)).toList());
});

// ── Send broadcast ────────────────────────────────────────────────────
Future<void> sendBroadcast(
  FirebaseFirestore db, {
  required String title,
  required String message,
  required String target,
  required String createdBy,
}) async {
  await db.collection('broadcasts').add({
    'title': title,
    'message': message,
    'target': target,
    'createdAt': FieldValue.serverTimestamp(),
    'createdBy': createdBy,
  });
}
