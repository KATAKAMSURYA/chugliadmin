import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/firebase_providers.dart';

// ── Reports across all rooms ──────────────────────────────────────────
// We collect reports from each room's subcollection
final allReportsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final db = ref.watch(firestoreProvider);

  return db
      .collection('rooms')
      .snapshots()
      .asyncMap((roomsSnap) async {
    final List<Map<String, dynamic>> allReports = [];
    for (final room in roomsSnap.docs) {
      final reportsSnap =
          await db.collection('rooms').doc(room.id).collection('reports').get();
      for (final reportDoc in reportsSnap.docs) {
        final data = Map<String, dynamic>.from(reportDoc.data());
        data['id'] = reportDoc.id;
        data['roomId'] = room.id;
        data['roomTitle'] = room.data()['title'] ?? 'Unknown Room';
        allReports.add(data);
      }
    }
    // Sort by timestamp descending
    allReports.sort((a, b) {
      final at = (a['timestamp'] as Timestamp?)?.toDate() ?? DateTime(0);
      final bt = (b['timestamp'] as Timestamp?)?.toDate() ?? DateTime(0);
      return bt.compareTo(at);
    });
    return allReports;
  });
});

// ── Update a report status ─────────────────────────────────────────────
Future<void> updateReportStatus(
  FirebaseFirestore db, {
  required String roomId,
  required String reportId,
  required String status,
}) {
  return db
      .collection('rooms')
      .doc(roomId)
      .collection('reports')
      .doc(reportId)
      .update({'status': status});
}
