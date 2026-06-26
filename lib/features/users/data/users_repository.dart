import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/firebase_providers.dart';

// ── Users list stream ────────────────────────────────────────────────
final usersStreamProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final db = ref.watch(firestoreProvider);
  return db
      .collection('users')
      .orderBy('updatedAt', descending: true)
      .limit(100)
      .snapshots()
      .map((snap) => snap.docs.map((doc) {
            final data = Map<String, dynamic>.from(doc.data());
            data['uid'] = doc.id;
            return data;
          }).toList());
});

// ── Suspend/ban a user ───────────────────────────────────────────────
Future<void> updateUserStatus(
  FirebaseFirestore db,
  String uid,
  Map<String, dynamic> fields,
) {
  return db.collection('users').doc(uid).update(fields);
}
