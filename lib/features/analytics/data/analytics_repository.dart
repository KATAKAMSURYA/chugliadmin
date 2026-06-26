import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/firebase_providers.dart';

// ── Room category breakdown ───────────────────────────────────────────
final roomCategoryStatsProvider =
    FutureProvider<Map<String, int>>((ref) async {
  final db = ref.watch(firestoreProvider);
  final snap = await db.collection('rooms').get();
  final Map<String, int> counts = {};
  for (final doc in snap.docs) {
    final category = doc.data()['category'] as String? ?? 'Other';
    counts[category] = (counts[category] ?? 0) + 1;
  }
  return counts;
});

// ── Active vs expired rooms ───────────────────────────────────────────
final roomStatusStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final db = ref.watch(firestoreProvider);
  final snap = await db.collection('rooms').get();
  int active = 0;
  int expired = 0;
  final now = DateTime.now();
  for (final doc in snap.docs) {
    final expiresAt = (doc.data()['expiresAt'] as Timestamp?)?.toDate();
    if (expiresAt != null && expiresAt.isAfter(now)) {
      active++;
    } else {
      expired++;
    }
  }
  return {'Active': active, 'Expired': expired};
});

// ── Reports by status ─────────────────────────────────────────────────
final reportStatusStatsProvider =
    FutureProvider<Map<String, int>>((ref) async {
  final db = ref.watch(firestoreProvider);
  final roomsSnap = await db.collection('rooms').get();
  final Map<String, int> statusCounts = {
    'Pending': 0,
    'Resolved': 0,
    'Rejected': 0,
  };
  for (final room in roomsSnap.docs) {
    final reportsSnap = await db
        .collection('rooms')
        .doc(room.id)
        .collection('reports')
        .get();
    for (final report in reportsSnap.docs) {
      final status = report.data()['status'] as String? ?? 'Pending';
      statusCounts[status] = (statusCounts[status] ?? 0) + 1;
    }
  }
  return statusCounts;
});

// ── User count ────────────────────────────────────────────────────────
final totalUsersCountProvider = FutureProvider<int>((ref) async {
  final db = ref.watch(firestoreProvider);
  final snap = await db.collection('users').count().get();
  return snap.count ?? 0;
});
