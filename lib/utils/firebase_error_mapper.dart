import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

/// Maps Firebase errors to user-friendly messages.
abstract final class FirebaseErrorMapper {
  static String authMessage(Object error) {
    if (error is FirebaseException && error.plugin != 'firebase_auth') {
      return _firestoreCodeMessage(error);
    }

    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return 'Enter a valid email address.';
        case 'user-disabled':
          return 'This account has been disabled.';
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Invalid email or password.';
        case 'email-already-in-use':
          return 'An account with this email already exists.';
        case 'weak-password':
          return 'Password must be at least 6 characters.';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';
        case 'network-request-failed':
          return 'Network error. Check your internet connection.';
        default:
          return error.message ?? 'Authentication failed.';
      }
    }

    return 'Something went wrong. Please try again.';
  }

  static String firestoreMessage(Object error) {
    if (error is FirebaseException) {
      return _firestoreCodeMessage(error);
    }
    final message = error.toString().toLowerCase();
    if (message.contains('network') || message.contains('unavailable')) {
      return 'Network error. Check your internet connection.';
    }
    return 'Failed to sync tasks. Please try again.';
  }

  static String _firestoreCodeMessage(FirebaseException error) {
    switch (error.code) {
      case 'permission-denied':
        return 'Database access denied. Publish Firestore security rules in Firebase Console.';
      case 'unavailable':
      case 'network-request-failed':
        return 'Network error. Check your internet connection.';
      default:
        return error.message ?? 'Database error. Please try again.';
    }
  }
}
