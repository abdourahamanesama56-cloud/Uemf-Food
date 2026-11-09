import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'auth_service.dart';
import 'cart_page.dart';
import 'l10n.dart';
import 'menu_data.dart';
import 'menu_page.dart';
import 'orders_page.dart';
import 'theme.dart';

/// Liste des restaurants de la cafétéria.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: lang,
      builder: (context, _) {
        final name = FirebaseAuth.instance.currentUser?.displayName ?? '';
        return Scaffold(
          appBar: AppBar(
            backgroundColor: kNavy,
            foregroundColor: Colors.white,
            title: const Text('UEMF Food'),
            actions: [
              const LangSwitch(),
              const CartButton(),
              IconButton(
                tooltip: lang.t('myOrders'),
                icon: const Icon(Icons.receipt_long_outlined),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const OrdersPage()),
                ),
              ),
              IconButton(
                tooltip: lang.t('logout'),
                icon: const Icon(Icons.logout),
                onPressed: AuthService.signOut,
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                '${lang.t('hello')} $name',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: kNavy,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(lang.t('choose')),
              const SizedBox(height: 16),
              for (final r in restaurants) _RestoCard(resto: r),
            ],
          ),
        );
      },
    );
  }
}

class _RestoCard extends StatelessWidget {
  final Restaurant resto;
  const _RestoCard({required this.resto});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => MenuPage(resto: resto)),
        ),
        child: Stack(
          children: [
            SizedBox(
              height: 150,
              width: double.infinity,
              child: Image.asset(
                resto.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) =>
                    ColoredBox(color: resto.color),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 12,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: resto.color,
                    child: Icon(resto.icon, size: 18, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      resto.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
