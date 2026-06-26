import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/firebase_providers.dart';

// ── Stream messages for a room ────────────────────────────────────────
final roomMessagesProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>((ref, roomId) {
  final db = ref.watch(firestoreProvider);
  return db
      .collection('rooms')
      .doc(roomId)
      .collection('messages')
      .orderBy('timestamp', descending: false)
      .snapshots()
      .map((snap) => snap.docs.map((doc) {
            final data = Map<String, dynamic>.from(doc.data());
            data['id'] = doc.id;
            return data;
          }).toList());
});

// ── Stream room title ────────────────────────────────────────────────
final roomTitleProvider =
    StreamProvider.family<String, String>((ref, roomId) {
  final db = ref.watch(firestoreProvider);
  return db
      .collection('rooms')
      .doc(roomId)
      .snapshots()
      .map((doc) => doc.data()?['title'] as String? ?? roomId);
});

// ── Delete a message ─────────────────────────────────────────────────
Future<void> deleteMessage(
    FirebaseFirestore db, String roomId, String messageId) {
  return db
      .collection('rooms')
      .doc(roomId)
      .collection('messages')
      .doc(messageId)
      .delete();
}
