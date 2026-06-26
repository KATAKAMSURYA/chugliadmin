import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/providers/firebase_providers.dart';

// ── Settings model ────────────────────────────────────────────────────
class AppSettings {
  final bool maintenanceMode;
  final int reportThreshold;
  final int maxParticipants;

  const AppSettings({
    this.maintenanceMode = false,
    this.reportThreshold = 5,
    this.maxParticipants = 50,
  });

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      maintenanceMode: map['maintenanceMode'] as bool? ?? false,
      reportThreshold: (map['reportThreshold'] as num?)?.toInt() ?? 5,
      maxParticipants: (map['maxParticipants'] as num?)?.toInt() ?? 50,
    );
  }

  Map<String, dynamic> toMap() => {
        'maintenanceMode': maintenanceMode,
        'reportThreshold': reportThreshold,
        'maxParticipants': maxParticipants,
        'updatedAt': FieldValue.serverTimestamp(),
      };
}

// ── Settings provider ─────────────────────────────────────────────────
final settingsProvider =
    StreamProvider<AppSettings>((ref) {
  final db = ref.watch(firestoreProvider);
  return db
      .collection('admin_settings')
      .doc('config')
      .snapshots()
      .map((doc) => doc.exists
          ? AppSettings.fromMap(doc.data()!)
          : const AppSettings());
});

// ── Save settings ─────────────────────────────────────────────────────
Future<void> saveSettings(
    FirebaseFirestore db, AppSettings settings) async {
  await db
      .collection('admin_settings')
      .doc('config')
      .set(settings.toMap(), SetOptions(merge: true));
}
