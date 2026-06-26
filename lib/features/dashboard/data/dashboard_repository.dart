import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/firebase_providers.dart';

// ── Dashboard stats model ────────────────────────────────────────────
class DashboardStats {
  final int totalRooms;
  final int activeRooms;
  final int totalUsers;
  final int pendingReports;

  const DashboardStats({
    required this.totalRooms,
    required this.activeRooms,
    required this.totalUsers,
    required this.pendingReports,
  });
}

// ── Dashboard Repository ─────────────────────────────────────────────
final dashboardStatsProvider = StreamProvider<DashboardStats>((ref) async* {
  final db = ref.watch(firestoreProvider);

  await for (final roomsSnap in db.collection('rooms').snapshots()) {
    final now = DateTime.now();
    final allRooms = roomsSnap.docs;
    final totalRooms = allRooms.length;
    final activeRooms = allRooms.where((doc) {
      final data = doc.data();
      final expiresAt = (data['expiresAt'] as Timestamp?)?.toDate();
      return expiresAt != null && expiresAt.isAfter(now);
    }).length;

    // Get users count
    final usersSnap = await db.collection('users').count().get();
    final totalUsers = usersSnap.count ?? 0;

    // Get pending reports count across all rooms
    int pendingReports = 0;
    for (final room in allRooms) {
      final reportsSnap = await db
          .collection('rooms')
          .doc(room.id)
          .collection('reports')
          .where('status', isEqualTo: 'Pending')
          .count()
          .get();
      pendingReports += reportsSnap.count ?? 0;
    }

    yield DashboardStats(
      totalRooms: totalRooms,
      activeRooms: activeRooms,
      totalUsers: totalUsers,
      pendingReports: pendingReports,
    );
  }
});

// ── Recent activity stream (recent messages across all rooms) ────────
final recentMessagesProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final db = ref.watch(firestoreProvider);
  final now = DateTime.now();
  final oneDayAgo = Timestamp.fromDate(now.subtract(const Duration(days: 1)));

  // Stream rooms and collect their latest messages
  return db
      .collection('rooms')
      .orderBy('createdAt', descending: true)
      .limit(10)
      .snapshots()
      .asyncMap((roomsSnap) async {
    final List<Map<String, dynamic>> recentMessages = [];
    for (final room in roomsSnap.docs) {
      final msgs = await db
          .collection('rooms')
          .doc(room.id)
          .collection('messages')
          .where('timestamp', isGreaterThan: oneDayAgo)
          .orderBy('timestamp', descending: true)
          .limit(3)
          .get();
      for (final msg in msgs.docs) {
        final data = Map<String, dynamic>.from(msg.data());
        data['id'] = msg.id;
        data['roomId'] = room.id;
        data['roomTitle'] = room.data()['title'] ?? 'Unknown Room';
        recentMessages.add(data);
      }
    }
    recentMessages.sort((a, b) {
      final at = (a['timestamp'] as Timestamp?)?.toDate() ?? DateTime(0);
      final bt = (b['timestamp'] as Timestamp?)?.toDate() ?? DateTime(0);
      return bt.compareTo(at);
    });
    return recentMessages.take(20).toList();
  });
});
