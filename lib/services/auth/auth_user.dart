import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/foundation.dart';

@immutable
class AuthUser {
  final String id;
  final String email;
  final bool isEmailVerified;
  const AuthUser({
    required this.id,
    required this.email,
    required this.isEmailVerified,
  });

  //Takes a Firebase Auth User and converts it into custom defined AuthUser
  factory AuthUser.fromFirebase(User user) => AuthUser(
        id: user.uid,
        isEmailVerified: user.emailVerified,
        email: user.email!,
      );
}
