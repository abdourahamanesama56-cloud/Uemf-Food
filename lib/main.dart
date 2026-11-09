import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'admin_page.dart';
import 'auth_page.dart';
import 'db.dart';
import 'firebase_options.dart';
import 'home_page.dart';
import 'theme.dart';

bool firebaseOk = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    firebaseOk = true;
  } catch (_) {
    firebaseOk = false;
  }
  runApp(const UemfFoodApp());
}

class UemfFoodApp extends StatelessWidget {
  const UemfFoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UEMF Food',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const _Root(),
    );
  }
}

class _Root extends StatelessWidget {
  const _Root();

  static const _loader = Scaffold(body: Center(child: CircularProgressIndicator()));

  @override
  Widget build(BuildContext context) {
    if (!firebaseOk) return const AuthPage();
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) return _loader;
        final user = snap.data;
        if (user == null) return const AuthPage();
        // Le rôle (student / admin) vient du document users/{uid}.
        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: Db.userDoc(user.uid),
          builder: (context, s) {
            if (s.connectionState == ConnectionState.waiting) return _loader;
            final m = s.data?.data();
            if (m != null && m['role'] == 'admin') {
              return AdminPage(restaurantId: m['restaurantId'] as String?);
            }
            return const HomePage();
          },
        );
      },
    );
  }
}
