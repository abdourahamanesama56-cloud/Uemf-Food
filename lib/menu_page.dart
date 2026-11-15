import 'package:flutter/material.dart';

import 'cart.dart';
import 'cart_page.dart';
import 'db.dart';
import 'dish_tile.dart';
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
  late final Stream<List<Review>> _reviews =
      Db.reviews(restaurantId: widget.resto.id);
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final resto = widget.resto;
    return ListenableBuilder(
      listenable: Listenable.merge([lang, cart]),
      builder: (context, _) {
        return Scaffold(
          bottomNavigationBar: _cartBar(context, resto),
          body: StreamBuilder<List<Review>>(
            stream: _reviews,
            builder: (context, rs) => StreamBuilder<List<Dish>>(
              stream: _menu,
              builder: (context, snap) {
                // Tant que le restaurant n'est pas initialisé, on affiche le menu local.
                final remote = snap.data ?? const <Dish>[];
                final all = remote.isNotEmpty ? remote : seedDishes(resto);
                final q = fold(_query.trim());
                final shown = q.isEmpty
                    ? all
                    : all
                        .where((d) =>
                            fold('${d.name} ${d.ingredients.join(' ')}')
                                .contains(q))
                        .toList();
                final groups = groupBySection(shown);
                final byDish =
                    ratingsBy(rs.data ?? const <Review>[], (r) => r.dishId);
                final side = sidePad(context);
                return CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      pinned: true,
                      expandedHeight: 130,
                      backgroundColor: resto.color,
                      foregroundColor: Colors.white,
                      actions: const [CartButton()],
                      flexibleSpace: FlexibleSpaceBar(
                        title: Text(resto.name),
                        background: Align(
                          alignment: Alignment.centerRight,
                          child: Image.asset(
                            resto.image,
                            height: 130,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stack) =>
                                const SizedBox.shrink(),
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(side, 16, side, 0),
                      sliver: SliverToBoxAdapter(
                        child: TextField(
                          onChanged: (v) => setState(() => _query = v),
                          decoration: InputDecoration(
                            hintText: lang.t('search'),
                            prefixIcon: const Icon(Icons.search),
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(side, 0, side, 24),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          if (groups.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 32),
                              child: Center(child: Text(lang.t('noResults'))),
                            ),
                          for (final e in groups.entries)
                            ..._section(e.key, e.value, byDish),
                        ]),
                      ),
                    ),
                  ],
                );
              },
            ),
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

  List<Widget> _section(
    String title,
    List<Dish> list,
    Map<String, Rating> byDish,
  ) {
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
              DishTile(
                dish: list[i],
                color: widget.resto.color,
                rating: byDish[list[i].id],
                restoName: widget.resto.name,
              ),
            ],
          ],
        ),
      ),
    ];
  }
}
