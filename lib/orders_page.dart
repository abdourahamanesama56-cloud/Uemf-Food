import 'package:flutter/material.dart';

import 'db.dart';
import 'l10n.dart';
import 'menu_data.dart';
import 'models.dart';
import 'theme.dart';

Color statusColor(String s) => s == 'ready'
    ? const Color(0xFF2E7D32)
    : s == 'validated'
        ? kNavy
        : kTerracotta;

String _two(int n) => n.toString().padLeft(2, '0');

String _time(DateTime t) =>
    '${_two(t.day)}/${_two(t.month)} ${_two(t.hour)}:${_two(t.minute)}';

/// Carte de commande, utilisée côté étudiant et côté admin.
class OrderCard extends StatelessWidget {
  final OrderDoc order;
  final bool showUser;
  final Widget? action;

  const OrderCard({
    super.key,
    required this.order,
    this.showUser = false,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final color = statusColor(order.status);
    final code = order.id.length >= 4 ? order.id.substring(0, 4) : order.id;
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: order.status == 'ready'
            ? BorderSide(color: color, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    showUser ? order.userName : order.restaurantName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: kNavy,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    lang.t(order.status),
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              '#${code.toUpperCase()} · ${_time(order.createdAt)}',
              style: const TextStyle(color: Colors.black54, fontSize: 12.5),
            ),
            const Divider(height: 20),
            for (final l in order.items)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Expanded(child: Text('${l.qty} × ${l.name}')),
                    Text(formatPrice(l.price * l.qty)),
                  ],
                ),
              ),
            if (order.note.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '“${order.note}”',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            const Divider(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    lang.t('total'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  formatPrice(order.total),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: kTerracotta,
                  ),
                ),
              ],
            ),
            if (action != null) ...[
              const SizedBox(height: 12),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Mes commandes (étudiant), mises à jour en direct.
class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  late final Stream<List<OrderDoc>> _orders = Db.myOrders();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: lang,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          backgroundColor: kNavy,
          foregroundColor: Colors.white,
          title: Text(lang.t('myOrders')),
        ),
        body: StreamBuilder<List<OrderDoc>>(
          stream: _orders,
          builder: (context, snap) {
            if (snap.hasError) {
              return Center(child: Text(lang.t('errGeneric')));
            }
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final list = snap.data!;
            if (list.isEmpty) {
              return Center(child: Text(lang.t('noOrders')));
            }
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [for (final o in list) OrderCard(order: o)],
            );
          },
        ),
      ),
    );
  }
}
