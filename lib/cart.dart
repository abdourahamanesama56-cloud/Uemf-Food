import 'package:flutter/material.dart';

import 'l10n.dart';
import 'models.dart';

class CartLine {
  final Dish dish;
  int qty;
  CartLine(this.dish, this.qty);
}

/// Panier : un seul restaurant à la fois.
class Cart extends ChangeNotifier {
  String? restaurantId;
  final Map<String, CartLine> lines = {};

  int get count => lines.values.fold(0, (n, l) => n + l.qty);

  double get total =>
      lines.values.fold(0.0, (t, l) => t + l.qty * l.dish.price);

  int qtyOf(String dishId) => lines[dishId]?.qty ?? 0;

  void add(Dish d) {
    if (restaurantId != d.restaurantId) {
      lines.clear();
      restaurantId = d.restaurantId;
    }
    final l = lines[d.id];
    if (l == null) {
      lines[d.id] = CartLine(d, 1);
    } else {
      l.qty++;
    }
    notifyListeners();
  }

  void remove(Dish d) {
    final l = lines[d.id];
    if (l == null) return;
    if (l.qty <= 1) {
      lines.remove(d.id);
    } else {
      l.qty--;
    }
    if (lines.isEmpty) restaurantId = null;
    notifyListeners();
  }

  void clear() {
    lines.clear();
    restaurantId = null;
    notifyListeners();
  }
}

final cart = Cart();

/// Ajoute un plat ; demande confirmation si le panier vient d'un autre restaurant.
Future<void> addToCart(BuildContext context, Dish d) async {
  if (cart.lines.isNotEmpty && cart.restaurantId != d.restaurantId) {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(lang.t('otherResto')),
        content: Text(lang.t('replaceCart')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(lang.t('cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(88, 44)),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(lang.t('ok')),
          ),
        ],
      ),
    );
    if (ok != true) return;
  }
  cart.add(d);
}
