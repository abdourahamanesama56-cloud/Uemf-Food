import 'package:flutter/material.dart';

import 'cart.dart';
import 'cart_page.dart';
import 'db.dart';
import 'l10n.dart';
import 'menu_data.dart';
import 'models.dart';
import 'theme.dart';

class MenuPage extends StatefulWidget {
  final Restaurant resto;
  const MenuPage({super.key, required this.resto});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  late final Stream<List<Dish>> _menu = Db.menu(widget.resto.id);

  @override
  Widget build(BuildContext context) {
    final resto = widget.resto;
    return ListenableBuilder(
      listenable: Listenable.merge([lang, cart]),
      builder: (context, _) {
        return Scaffold(
          bottomNavigationBar: _cartBar(context, resto),
          body: StreamBuilder<List<Dish>>(
            stream: _menu,
            builder: (context, snap) {
              // Tant que l'admin n'a pas initialisé la base, on affiche le menu local.
              final remote = snap.data ?? const <Dish>[];
              final dishes = remote.isNotEmpty ? remote : seedDishes(resto);
              final groups = groupBySection(dishes);
              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    expandedHeight: 170,
                    backgroundColor: resto.color,
                    foregroundColor: Colors.white,
                    actions: const [CartButton()],
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(resto.name),
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            resto.image,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stack) =>
                                ColoredBox(color: resto.color),
                          ),
                          const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0x33000000), Color(0xAA000000)],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        for (final e in groups.entries)
                          ..._section(e.key, e.value),
                      ]),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget? _cartBar(BuildContext context, Restaurant r) {
    if (cart.count == 0 || cart.restaurantId != r.id) return null;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: FilledButton.icon(
          icon: const Icon(Icons.shopping_cart),
          label: Text(
            '${lang.t('cart')} · ${cart.count} · ${formatPrice(cart.total)}',
          ),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CartPage()),
          ),
        ),
      ),
    );
  }

  List<Widget> _section(String title, List<Dish> list) {
    final note = list.first.note;
    return [
      Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: Row(
          children: [
            Flexible(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: kNavy,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            if (note != null && note.isNotEmpty) ...[
              const SizedBox(width: 8),
              Chip(
                label: Text(note),
                visualDensity: VisualDensity.compact,
                backgroundColor: widget.resto.color.withValues(alpha: 0.12),
                side: BorderSide.none,
              ),
            ],
          ],
        ),
      ),
      Card(
        margin: EdgeInsets.zero,
        color: Colors.white,
        elevation: 0,
        child: Column(
          children: [
            for (var i = 0; i < list.length; i++) ...[
              if (i > 0) const Divider(height: 1),
              _DishRow(dish: list[i]),
            ],
          ],
        ),
      ),
    ];
  }
}

class _DishRow extends StatelessWidget {
  final Dish dish;
  const _DishRow({required this.dish});

  @override
  Widget build(BuildContext context) {
    final q = cart.qtyOf(dish.id);
    final off = !dish.available;
    final desc = dish.desc;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dish.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: off ? Colors.grey : null,
                    decoration: off ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (desc != null && desc.isNotEmpty)
                  Text(
                    desc,
                    style: const TextStyle(fontSize: 12.5, color: Colors.black54),
                  ),
                const SizedBox(height: 2),
                Text(
                  formatPrice(dish.price),
                  style: const TextStyle(
                    color: kTerracotta,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (off)
            Text(
              lang.t('soldOut'),
              style: const TextStyle(
                color: Color(0xFFB3261E),
                fontWeight: FontWeight.bold,
              ),
            )
          else if (q == 0)
            IconButton.filled(
              style: IconButton.styleFrom(
                backgroundColor: kTerracotta,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.add),
              onPressed: () => addToCart(context, dish),
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () => cart.remove(dish),
                ),
                Text('$q', style: const TextStyle(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: kTerracotta),
                  onPressed: () => addToCart(context, dish),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
