import 'package:flutter/material.dart';

import 'cart.dart';
import 'cart_page.dart';
import 'db.dart';
import 'l10n.dart';
import 'menu_data.dart';
import 'models.dart';
import 'theme.dart';
import 'widgets.dart';

String _two(int n) => n.toString().padLeft(2, '0');

/// Détail d'un plat : photo, ingrédients, avis des clients ayant commandé.
class DishPage extends StatefulWidget {
  final Dish dish;
  final Color color;
  final String? restoName;

  const DishPage({
    super.key,
    required this.dish,
    required this.color,
    this.restoName,
  });

  @override
  State<DishPage> createState() => _DishPageState();
}

class _DishPageState extends State<DishPage> {
  late final Stream<List<Review>> _reviews =
      Db.reviews(dishId: widget.dish.id);

  Widget _title(String t) => Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 8),
        child: Text(
          t,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: kNavy,
          ),
        ),
      );

  Widget _bar(BuildContext context) {
    final d = widget.dish;
    final q = cart.qtyOf(d.id);
    final Widget content;
    if (!d.available) {
      content = FilledButton(onPressed: null, child: Text(lang.t('soldOut')));
    } else if (q == 0) {
      content = FilledButton.icon(
        icon: const Icon(Icons.add_shopping_cart),
        label: Text('${lang.t('addToCart')} · ${formatPrice(d.price)}'),
        onPressed: () => addToCart(context, d),
      );
    } else {
      content = Row(
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: () => cart.remove(d),
          ),
          Text(
            '$q',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle, color: kTerracotta),
            onPressed: () => addToCart(context, d),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: FilledButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CartPage()),
              ),
              child: Text(
                '${lang.t('viewCart')} · ${formatPrice(cart.total)}',
              ),
            ),
          ),
        ],
      );
    }
    return SafeArea(
      child: Padding(padding: const EdgeInsets.all(12), child: content),
    );
  }

  Widget _reviewCard(Review r) {
    final c = widget.color;
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: c,
                  child: Text(
                    r.userName.isEmpty ? '?' : r.userName[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    r.userName.isEmpty ? '—' : r.userName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  '${_two(r.createdAt.day)}/${_two(r.createdAt.month)}/${r.createdAt.year}',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                for (var i = 1; i <= 5; i++)
                  Icon(
                    i <= r.rating ? Icons.star : Icons.star_border,
                    size: 16,
                    color: kGold,
                  ),
                const SizedBox(width: 8),
                Text(
                  lang.t('verified'),
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
            if (r.comment.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(r.comment),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.dish;
    final c = widget.color;
    final resto = widget.restoName;
    return ListenableBuilder(
      listenable: Listenable.merge([lang, cart]),
      builder: (context, _) => Scaffold(
        bottomNavigationBar: _bar(context),
        body: StreamBuilder<List<Review>>(
          stream: _reviews,
          builder: (context, snap) {
            final rs = snap.data ?? const <Review>[];
            final rating = rs.isEmpty
                ? null
                : Rating(
                    rs.fold<int>(0, (s, r) => s + r.rating) / rs.length,
                    rs.length,
                  );
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 240,
                  backgroundColor: c,
                  foregroundColor: Colors.white,
                  actions: const [CartButton()],
                  flexibleSpace: FlexibleSpaceBar(
                    background: DishImage(path: d.image, color: c),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: sidePad(context),
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          d.name,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: kNavy,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        if (resto != null)
                          Text(
                            resto,
                            style: TextStyle(
                              color: c,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              formatPrice(d.price),
                              style: const TextStyle(
                                color: kTerracotta,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            const Spacer(),
                            RatingLabel(rating: rating),
                          ],
                        ),
                        if (!d.available)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              lang.t('soldOut'),
                              style: const TextStyle(
                                color: Color(0xFFB3261E),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (d.ingredients.isNotEmpty) ...[
                          _title(lang.t('ingredients')),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final i in d.ingredients)
                                Chip(
                                  label: Text(i),
                                  visualDensity: VisualDensity.compact,
                                  backgroundColor: c.withValues(alpha: 0.1),
                                  side: BorderSide.none,
                                ),
                            ],
                          ),
                        ],
                        _title(lang.t('reviewsTitle')),
                        if (rs.isEmpty)
                          Text(
                            lang.t('noReviewsYet'),
                            style: const TextStyle(color: Colors.black54),
                          )
                        else
                          for (final r in rs) _reviewCard(r),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
