import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'cart.dart';

class AuthService {
  static Future<void> signIn(String email, String password) async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  static Future<void> register(
    String name,
    String email,
    String password,
  ) async {
    final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = cred.user!;
    await user.updateDisplayName(name.trim());
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'role': 'student',
      'createdAt': FieldValue.serverTimestamp(),
    });
    await user.sendEmailVerification();
  }

  static Future<void> signOut() {
    cart.clear();
    return FirebaseAuth.instance.signOut();
  }

  /// Clé de traduction (l10n) correspondant à un code d'erreur Firebase.
  static String errorKey(String code) {
    switch (code) {
      case 'invalid-credential':
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-email':
        return 'errCreds';
      case 'email-already-in-use':
        return 'errExists';
      case 'weak-password':
        return 'errPass';
      case 'network-request-failed':
        return 'errNet';
      default:
        return 'errGeneric';
    }
  }
}
