import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/firebase_providers.dart';

// ── Rooms list stream ─────────────────────────────────────────────────
final roomsStreamProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final db = ref.watch(firestoreProvider);
  return db
      .collection('rooms')
      .orderBy('createdAt', descending: true)
      .limit(100)
      .snapshots()
      .map((snap) => snap.docs.map((doc) {
            final data = Map<String, dynamic>.from(doc.data());
            data['id'] = doc.id;
            final expiresAt = (data['expiresAt'] as Timestamp?)?.toDate();
            data['isActive'] = expiresAt != null && expiresAt.isAfter(DateTime.now());
            final uids = List<String>.from(data['participantUids'] ?? []);
            data['participantCount'] = uids.isEmpty ? 1 : uids.length;
            return data;
          }).toList());
});

// ── Delete a room ─────────────────────────────────────────────────────
Future<void> deleteRoom(FirebaseFirestore db, String roomId) {
  return db.collection('rooms').doc(roomId).delete();
}
