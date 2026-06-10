import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../models/user.dart';

/// Data layer for Firebase Authentication and user profiles.
class AuthRepository {
  AuthRepository(this._auth, this._firestore);

  final firebase_auth.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<firebase_auth.User?> get authStateChanges => _auth.authStateChanges();

  Future<AppUser> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.toLowerCase().trim(),
      password: password,
    );

    final firebaseUser = credential.user;
    if (firebaseUser == null) {
      throw firebase_auth.FirebaseAuthException(
        code: 'user-not-found',
        message: 'Account could not be created.',
      );
    }

    await firebaseUser.updateDisplayName(name.trim());

    final appUser = AppUser.fromFirebaseUser(
      firebaseUser,
      name: name.trim(),
    );

    try {
      await _firestore.collection('users').doc(appUser.id).set({
        ...appUser.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Auth succeeded; profile sync can retry on next login.
    }

    return appUser;
  }

  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.toLowerCase().trim(),
      password: password,
    );

    final firebaseUser = credential.user;
    if (firebaseUser == null) {
      throw firebase_auth.FirebaseAuthException(
        code: 'user-not-found',
        message: 'Invalid email or password.',
      );
    }

    return _loadUserProfile(firebaseUser);
  }

  Future<void> logout() => _auth.signOut();

  Future<AppUser?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    return _loadUserProfile(firebaseUser);
  }

  Future<AppUser> _loadUserProfile(firebase_auth.User firebaseUser) async {
    try {
      final doc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();

      if (doc.exists && doc.data() != null) {
        return AppUser.fromMap(id: firebaseUser.uid, map: doc.data()!);
      }

      final appUser = AppUser.fromFirebaseUser(firebaseUser);
      await _firestore.collection('users').doc(appUser.id).set({
        ...appUser.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return appUser;
    } catch (_) {
      return AppUser.fromFirebaseUser(firebaseUser);
    }
  }
}
