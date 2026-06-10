import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

/// Domain model representing an authenticated user.
class AppUser {
  AppUser({
    required this.id,
    required this.name,
    required this.email,
  });

  final String id;
  final String name;
  final String email;

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
      };

  factory AppUser.fromMap({
    required String id,
    required Map<String, dynamic> map,
  }) {
    return AppUser(
      id: id,
      name: map['name'] as String? ?? 'User',
      email: map['email'] as String? ?? '',
    );
  }

  factory AppUser.fromFirebaseUser(
    firebase_auth.User user, {
    String? name,
  }) {
    return AppUser(
      id: user.uid,
      name: name ?? user.displayName ?? 'User',
      email: user.email ?? '',
    );
  }
}
