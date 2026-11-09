import 'package:cloud_firestore/cloud_firestore.dart';

import 'menu_data.dart';

/// Un plat du menu (stocké dans Firestore, collection `menu_items`).
class Dish {
  final String id;
  final String restaurantId;
  final String section;
  final String? note;
  final String name;
  final String? desc;
  final double price;
  final bool available;
  final int order;

  const Dish({
    required this.id,
    required this.restaurantId,
    required this.section,
    this.note,
    required this.name,
    this.desc,
    required this.price,
    this.available = true,
    required this.order,
  });

  factory Dish.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? <String, dynamic>{};
    return Dish(
      id: d.id,
      restaurantId: m['restaurantId'] as String? ?? '',
      section: m['section'] as String? ?? '',
      note: m['note'] as String?,
      name: m['name'] as String? ?? '',
      desc: m['desc'] as String?,
      price: (m['price'] as num?)?.toDouble() ?? 0,
      available: m['available'] as bool? ?? true,
      order: (m['order'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'restaurantId': restaurantId,
        'section': section,
        'note': note,
        'name': name,
        'desc': desc,
        'price': price,
        'available': available,
        'order': order,
      };
}

/// Menu de départ (données locales), identique à ce que l'admin initialise.
List<Dish> seedDishes(Restaurant r) {
  final out = <Dish>[];
  var n = 0;
  for (final s in r.sections) {
    for (final it in s.items) {
      out.add(Dish(
        id: '${r.id}_$n',
        restaurantId: r.id,
        section: s.title,
        note: s.note,
        name: it.name,
        desc: it.desc,
        price: it.price,
        order: n,
      ));
      n++;
    }
  }
  return out;
}

/// Regroupe les plats par rubrique, dans l'ordre d'affichage.
Map<String, List<Dish>> groupBySection(List<Dish> dishes) {
  final sorted = [...dishes]..sort((a, b) => a.order.compareTo(b.order));
  final out = <String, List<Dish>>{};
  for (final d in sorted) {
    out.putIfAbsent(d.section, () => []).add(d);
  }
  return out;
}

class OrderLine {
  final String name;
  final double price;
  final int qty;
  const OrderLine({required this.name, required this.price, required this.qty});
}

/// Une commande (collection `orders`).
/// status : pending -> validated -> ready
class OrderDoc {
  final String id;
  final String userName;
  final String restaurantId;
  final String restaurantName;
  final String note;
  final String status;
  final double total;
  final DateTime createdAt;
  final List<OrderLine> items;

  const OrderDoc({
    required this.id,
    required this.userName,
    required this.restaurantId,
    required this.restaurantName,
    required this.note,
    required this.status,
    required this.total,
    required this.createdAt,
    required this.items,
  });

  factory OrderDoc.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? <String, dynamic>{};
    final raw = (m['items'] as List?) ?? const [];
    return OrderDoc(
      id: d.id,
      userName: m['userName'] as String? ?? '',
      restaurantId: m['restaurantId'] as String? ?? '',
      restaurantName: m['restaurantName'] as String? ?? '',
      note: m['note'] as String? ?? '',
      status: m['status'] as String? ?? 'pending',
      total: (m['total'] as num?)?.toDouble() ?? 0,
      createdAt: (m['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      items: raw.map((e) {
        final x = Map<String, dynamic>.from(e as Map);
        return OrderLine(
          name: x['name'] as String? ?? '',
          price: (x['price'] as num?)?.toDouble() ?? 0,
          qty: (x['qty'] as num?)?.toInt() ?? 1,
        );
      }).toList(),
    );
  }
}
