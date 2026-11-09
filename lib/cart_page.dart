import 'package:flutter/material.dart';

import 'cart.dart';
import 'db.dart';
import 'l10n.dart';
import 'menu_data.dart';
import 'orders_page.dart';
import 'theme.dart';

/// Icône panier avec compteur (barre d'application).
class CartButton extends StatelessWidget {
  const CartButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: cart,
      builder: (context, _) => IconButton(
        tooltip: lang.t('cart'),
        icon: Badge(
          isLabelVisible: cart.count > 0,
          label: Text('${cart.count}'),
          child: const Icon(Icons.shopping_cart_outlined),
        ),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CartPage()),
        ),
      ),
    );
  }
}

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final _note = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final r = restaurantById(cart.restaurantId);
    if (r == null) return;
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    setState(() => _sending = true);
    try {
      await Db.placeOrder(r, _note.text);
      cart.clear();
      nav.pushReplacement(
        MaterialPageRoute(builder: (_) => const OrdersPage()),
      );
      messenger.showSnackBar(SnackBar(content: Text(lang.t('orderSent'))));
    } catch (_) {
      if (mounted) setState(() => _sending = false);
      messenger.showSnackBar(SnackBar(content: Text(lang.t('errOrder'))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([lang, cart]),
      builder: (context, _) {
        final r = restaurantById(cart.restaurantId);
        return Scaffold(
          appBar: AppBar(
            backgroundColor: kNavy,
            foregroundColor: Colors.white,
            title: Text(
              r == null ? lang.t('cart') : '${lang.t('cart')} · ${r.name}',
            ),
          ),
          body: cart.count == 0
              ? Center(child: Text(lang.t('cartEmpty')))
              : Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          for (final l in cart.lines.values.toList())
                            Card(
                              color: Colors.white,
                              elevation: 0,
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                title: Text(
                                  l.dish.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  formatPrice(l.dish.price * l.qty),
                                  style: const TextStyle(
                                    color: kTerracotta,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                      ),
                                      onPressed: () => cart.remove(l.dish),
                                    ),
                                    Text(
                                      '${l.qty}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.add_circle,
                                        color: kTerracotta,
                                      ),
                                      onPressed: () => cart.add(l.dish),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextField(
                              controller: _note,
                              maxLines: 2,
                              decoration: InputDecoration(
                                labelText: lang.t('note'),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    lang.t('total'),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                Text(
                                  formatPrice(cart.total),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: kTerracotta,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              lang.t('payAtPickup'),
                              style: const TextStyle(color: Colors.black54),
                            ),
                            const SizedBox(height: 12),
                            FilledButton(
                              onPressed: _sending ? null : _send,
                              child: _sending
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(lang.t('order')),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
