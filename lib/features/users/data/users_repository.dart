import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/firebase_providers.dart';

// ── Users list stream ────────────────────────────────────────────────
final usersStreamProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final db = ref.watch(firestoreProvider);
  return db
      .collection('users')
      .limit(500)
      .snapshots()
      .map((snap) {
        final users = snap.docs.map((doc) {
          final data = Map<String, dynamic>.from(doc.data());
          data['uid'] = doc.id;
          return data;
        }).toList();

        users.sort((a, b) {
          final aDate = (a['createdAt'] as dynamic)?.toDate?.call() as DateTime? ?? 
                        (a['updatedAt'] as dynamic)?.toDate?.call() as DateTime?;
          final bDate = (b['createdAt'] as dynamic)?.toDate?.call() as DateTime? ?? 
                        (b['updatedAt'] as dynamic)?.toDate?.call() as DateTime?;
          
          if (aDate == null && bDate == null) return 0;
          if (aDate == null) return 1;
          if (bDate == null) return -1;
          
          return bDate.compareTo(aDate);
        });

        return users;
      });
});

// ── Suspend/ban a user ───────────────────────────────────────────────
Future<void> updateUserStatus(
  FirebaseFirestore db,
  String uid,
  Map<String, dynamic> fields,
) {
  return db.collection('users').doc(uid).update(fields);
}
