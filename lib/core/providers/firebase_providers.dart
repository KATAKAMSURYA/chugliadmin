import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Firebase instances ───────────────────────────────────────────────
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

// ── Auth state ────────────────────────────────────────────────────────
final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

// ── Admin auth provider: true if logged in via email ──────────────────
final isAdminAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(authStateChangesProvider).asData?.value;
  // Admin must be logged in with email (not anonymous)
  return user != null && !user.isAnonymous;
});
