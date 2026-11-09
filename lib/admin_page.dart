import 'package:flutter/material.dart';

import 'auth_service.dart';
import 'db.dart';
import 'l10n.dart';
import 'menu_data.dart';
import 'models.dart';
import 'orders_page.dart';
import 'theme.dart';

/// Espace admin d'un restaurant : commandes en direct + gestion du menu.
class AdminPage extends StatefulWidget {
  final String? restaurantId;
  const AdminPage({super.key, this.restaurantId});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  late final Stream<List<OrderDoc>> _orders =
      Db.restaurantOrders(widget.restaurantId ?? '');

  @override
  Widget build(BuildContext context) {
    final r = restaurantById(widget.restaurantId);
    if (r == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: kNavy,
          foregroundColor: Colors.white,
          title: const Text('UEMF Food'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: AuthService.signOut,
            ),
          ],
        ),
        body: Center(child: Text(lang.t('adminNoResto'))),
      );
    }
    return ListenableBuilder(
      listenable: lang,
      builder: (context, _) => StreamBuilder<List<OrderDoc>>(
        stream: _orders,
        builder: (context, snap) {
          final all = snap.data ?? const <OrderDoc>[];
          List<OrderDoc> by(String s) =>
              all.where((o) => o.status == s).toList();
          // Les plus anciennes d'abord pour traiter dans l'ordre d'arrivée.
          final pending = by('pending').reversed.toList();
          final validated = by('validated').reversed.toList();
          final ready = by('ready');
          return DefaultTabController(
            length: 4,
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: kNavy,
                foregroundColor: Colors.white,
                title: Text('${r.name} · ${lang.t('admin')}'),
                actions: [
                  const LangSwitch(),
                  IconButton(
                    tooltip: lang.t('logout'),
                    icon: const Icon(Icons.logout),
                    onPressed: AuthService.signOut,
                  ),
                ],
                bottom: TabBar(
                  isScrollable: true,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  indicatorColor: kTerracotta,
                  tabs: [
                    Tab(text: '${lang.t('pending')} (${pending.length})'),
                    Tab(text: '${lang.t('validated')} (${validated.length})'),
                    Tab(text: lang.t('readyTab')),
                    Tab(text: lang.t('menu')),
                  ],
                ),
              ),
              body: TabBarView(
                children: [
                  _OrderList(orders: pending),
                  _OrderList(orders: validated),
                  _OrderList(orders: ready),
                  _MenuTab(resto: r),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  final List<OrderDoc> orders;
  const _OrderList({required this.orders});

  Widget? _action(OrderDoc o) {
    if (o.status == 'pending') {
      return FilledButton.icon(
        icon: const Icon(Icons.check),
        label: Text(lang.t('validate')),
        onPressed: () => Db.setStatus(o.id, 'validated'),
      );
    }
    if (o.status == 'validated') {
      return FilledButton.icon(
        icon: const Icon(Icons.notifications_active_outlined),
        label: Text(lang.t('ready')),
        onPressed: () => Db.setStatus(o.id, 'ready'),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) return Center(child: Text(lang.t('nothing')));
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final o in orders)
          OrderCard(order: o, showUser: true, action: _action(o)),
      ],
    );
  }
}

class _MenuTab extends StatefulWidget {
  final Restaurant resto;
  const _MenuTab({required this.resto});

  @override
  State<_MenuTab> createState() => _MenuTabState();
}

class _MenuTabState extends State<_MenuTab> {
  late final Stream<List<Dish>> _menu = Db.menu(widget.resto.id);

  @override
  Widget build(BuildContext context) {
    final r = widget.resto;
    return StreamBuilder<List<Dish>>(
      stream: _menu,
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(child: Text(lang.t('errGeneric')));
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final dishes = snap.data!;
        if (dishes.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(lang.t('initMenuInfo'), textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => Db.seedMenu(r),
                    child: Text(lang.t('initMenu')),
                  ),
                ],
              ),
            ),
          );
        }
        final groups = groupBySection(dishes);
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            FilledButton.icon(
              icon: const Icon(Icons.add),
              label: Text(lang.t('addDish')),
              onPressed: () => _editDish(context, r.id, null, dishes),
            ),
            for (final e in groups.entries) ...[
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 8),
                child: Text(
                  e.key,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: kNavy,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Card(
                margin: EdgeInsets.zero,
                color: Colors.white,
                elevation: 0,
                child: Column(
                  children: [
                    for (final d in e.value)
                      ListTile(
                        title: Text(
                          d.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            decoration: d.available
                                ? null
                                : TextDecoration.lineThrough,
                          ),
                        ),
                        subtitle: Text(
                          d.available
                              ? formatPrice(d.price)
                              : '${formatPrice(d.price)} · ${lang.t('soldOut')}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch(
                              value: d.available,
                              onChanged: (v) => Db.setAvailable(d, v),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () =>
                                  _editDish(context, r.id, d, dishes),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Ajout (d == null) ou modification / suppression d'un plat.
Future<void> _editDish(
  BuildContext context,
  String rid,
  Dish? d,
  List<Dish> all,
) async {
  final section = TextEditingController(
    text: d?.section ?? (all.isNotEmpty ? all.last.section : ''),
  );
  final name = TextEditingController(text: d?.name ?? '');
  final price = TextEditingController(
    text: d == null
        ? ''
        : (d.price == d.price.roundToDouble()
            ? d.price.toStringAsFixed(0)
            : d.price.toString()),
  );
  final desc = TextEditingController(text: d?.desc ?? '');

  final res = await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(lang.t(d == null ? 'addDish' : 'editDish')),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: section,
              decoration: InputDecoration(labelText: lang.t('section')),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: name,
              decoration: InputDecoration(labelText: lang.t('dishName')),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: price,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: lang.t('price')),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: desc,
              decoration: InputDecoration(labelText: lang.t('desc')),
            ),
          ],
        ),
      ),
      actions: [
        if (d != null)
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'delete'),
            child: Text(
              lang.t('delete'),
              style: const TextStyle(color: Color(0xFFB3261E)),
            ),
          ),
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(lang.t('cancel')),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(88, 44)),
          onPressed: () => Navigator.pop(ctx, 'save'),
          child: Text(lang.t('save')),
        ),
      ],
    ),
  );

  try {
    if (res == 'delete' && d != null) {
      await Db.deleteDish(d);
      return;
    }
    if (res != 'save') return;

    final p = double.tryParse(price.text.trim().replaceAll(',', '.'));
    final sec = section.text.trim();
    if (name.text.trim().isEmpty || sec.isEmpty || p == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(lang.t('errPrice'))));
      }
      return;
    }
    String? note;
    for (final e in all) {
      if (e.section == sec) {
        note = e.note;
        break;
      }
    }
    final maxOrder = all.fold<int>(0, (m, e) => e.order > m ? e.order : m);
    final descText = desc.text.trim();
    await Db.saveDish(Dish(
      id: d?.id ?? Db.newDishId(),
      restaurantId: rid,
      section: sec,
      note: note,
      name: name.text.trim(),
      desc: descText.isEmpty ? null : descText,
      price: p,
      available: d?.available ?? true,
      order: d?.order ?? maxOrder + 1,
    ));
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(lang.t('errGeneric'))));
    }
  }
}
