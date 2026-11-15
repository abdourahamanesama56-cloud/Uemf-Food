import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'auth_service.dart';
import 'cart.dart';
import 'cart_page.dart';
import 'db.dart';
import 'dish_page.dart';
import 'dish_tile.dart';
import 'l10n.dart';
import 'menu_data.dart';
import 'menu_page.dart';
import 'models.dart';
import 'orders_page.dart';
import 'theme.dart';
import 'widgets.dart';

/// Accueil façon Glovo : recherche, plats recommandés, restaurants.
class HomePage extends StatefulWidget {
  final bool isOwner;
  const HomePage({super.key, this.isOwner = false});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Stream<List<RestoDoc>> _restos = Db.restaurants();
  late final Stream<List<Dish>> _menu = Db.allMenu();
  late final Stream<List<Review>> _reviews = Db.reviews();
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  /// Compte « owner » : enregistre restaurants et plats dans Firestore.
  Future<void> _seedAll() async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(lang.t('seedAll')),
        content: Text(lang.t('seedAllInfo')),
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
    try {
      await Db.seedAll();
      messenger.showSnackBar(SnackBar(content: Text(lang.t('seeded'))));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(lang.t('errGeneric'))));
    }
  }

  Widget _title(String t) => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 10),
        child: Text(
          t,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: kNavy,
          ),
        ),
      );

  List<Widget> _content(
    BuildContext context,
    List<Restaurant> restos,
    List<Dish> dishes,
    Map<String, Rating> byResto,
    Map<String, Rating> byDish,
  ) {
    final name = FirebaseAuth.instance.currentUser?.displayName ?? '';
    final restoMap = {for (final r in restos) r.id: r};
    final q = fold(_query.trim());

    final children = <Widget>[
      Text(
        '${lang.t('hello')} $name',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: kNavy,
              fontWeight: FontWeight.bold,
            ),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _search,
        onChanged: (v) => setState(() => _query = v),
        decoration: InputDecoration(
          hintText: lang.t('search'),
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _query.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _search.clear();
                    setState(() => _query = '');
                  },
                ),
        ),
      ),
      const SizedBox(height: 16),
    ];

    if (q.isEmpty) {
      final top = dishes
          .where((d) =>
              (byDish[d.id]?.avg ?? 0) >= 4 && restoMap.containsKey(d.restaurantId))
          .toList()
        ..sort((a, b) => byDish[b.id]!.avg.compareTo(byDish[a.id]!.avg));
      final reco = top.take(8).toList();
      if (reco.isNotEmpty) {
        children.add(_title(lang.t('recommended')));
        children.add(
          SizedBox(
            height: 205,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final d in reco)
                  _RecoCard(
                    dish: d,
                    resto: restoMap[d.restaurantId]!,
                    rating: byDish[d.id],
                  ),
              ],
            ),
          ),
        );
        children.add(const SizedBox(height: 8));
      }
      children.add(_title(lang.t('restosTitle')));
      for (final r in restos) {
        final rd = dishes.where((d) => d.restaurantId == r.id).toList();
        children.add(
          _RestoCard(
            resto: r,
            rating: byResto[r.id],
            count: rd.length,
            sections: groupBySection(rd).keys.take(4).join(' · '),
          ),
        );
      }
    } else {
      final matchR = restos.where((r) => fold(r.name).contains(q)).toList();
      final matchD = dishes.where((d) {
        final r = restoMap[d.restaurantId];
        return fold('${d.name} ${d.ingredients.join(' ')} ${r?.name ?? ''}')
            .contains(q);
      }).toList();
      if (matchR.isEmpty && matchD.isEmpty) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(top: 32),
            child: Center(child: Text(lang.t('noResults'))),
          ),
        );
      }
      for (final r in matchR) {
        final rd = dishes.where((d) => d.restaurantId == r.id).toList();
        children.add(
          _RestoCard(
            resto: r,
            rating: byResto[r.id],
            count: rd.length,
            sections: groupBySection(rd).keys.take(4).join(' · '),
          ),
        );
      }
      if (matchD.isNotEmpty) {
        children.add(
          Card(
            margin: EdgeInsets.zero,
            color: Colors.white,
            elevation: 0,
            child: Column(
              children: [
                for (var i = 0; i < matchD.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  DishTile(
                    dish: matchD[i],
                    color: restoMap[matchD[i].restaurantId]?.color ?? kNavy,
                    rating: byDish[matchD[i].id],
                    restoName: restoMap[matchD[i].restaurantId]?.name,
                    showResto: true,
                  ),
                ],
              ],
            ),
          ),
        );
      }
    }
    return children;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([lang, cart]),
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          backgroundColor: kNavy,
          foregroundColor: Colors.white,
          title: const Text('UEMF Food'),
          actions: [
            if (widget.isOwner)
              IconButton(
                tooltip: lang.t('seedAll'),
                icon: const Icon(Icons.cloud_upload_outlined),
                onPressed: _seedAll,
              ),
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
        body: StreamBuilder<List<RestoDoc>>(
          stream: _restos,
          builder: (context, s1) => StreamBuilder<List<Dish>>(
            stream: _menu,
            builder: (context, s2) => StreamBuilder<List<Review>>(
              stream: _reviews,
              builder: (context, s3) {
                final restos = mergeRestos(s1.data ?? const <RestoDoc>[]);
                final dishes = mergeMenus(s2.data ?? const <Dish>[]);
                final reviews = s3.data ?? const <Review>[];
                return ListView(
                  padding: EdgeInsets.symmetric(
                    horizontal: sidePad(context),
                    vertical: 16,
                  ),
                  children: _content(
                    context,
                    restos,
                    dishes,
                    ratingsBy(reviews, (r) => r.restaurantId),
                    ratingsBy(reviews, (r) => r.dishId),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _RestoCard extends StatelessWidget {
  final Restaurant resto;
  final Rating? rating;
  final int count;
  final String sections;

  const _RestoCard({
    required this.resto,
    required this.rating,
    required this.count,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => MenuPage(resto: resto)),
        ),
        child: SizedBox(
          height: 120,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 560 / 308,
                child: Image.asset(
                  resto.image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) =>
                      ColoredBox(color: resto.color),
                ),
              ),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resto.name,
                        style: const TextStyle(
                          color: kNavy,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        sections,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          RatingLabel(rating: rating),
                          const SizedBox(width: 10),
                          Text(
                            '$count ${lang.t('dishesWord')}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecoCard extends StatelessWidget {
  final Dish dish;
  final Restaurant resto;
  final Rating? rating;

  const _RecoCard({
    required this.dish,
    required this.resto,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: SizedBox(
        width: 150,
        child: Card(
          clipBehavior: Clip.antiAlias,
          margin: EdgeInsets.zero,
          color: Colors.white,
          elevation: 0,
          child: InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => DishPage(
                  dish: dish,
                  color: resto.color,
                  restoName: resto.name,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DishImage(
                  path: dish.image,
                  color: resto.color,
                  width: 150,
                  height: 100,
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dish.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                          color: kNavy,
                        ),
                      ),
                      const SizedBox(height: 3),
                      RatingLabel(rating: rating),
                      Text(
                        formatPrice(dish.price),
                        style: const TextStyle(
                          color: kTerracotta,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
