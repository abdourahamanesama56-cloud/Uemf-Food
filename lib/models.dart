import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'menu_data.dart';
import 'theme.dart';

/// Un plat du menu (Firestore, collection `menu_items`).
class Dish {
  final String id;
  final String restaurantId;
  final String section;
  final String? note;
  final String name;
  final List<String> ingredients;
  final String? image; // chemin d'asset ou lien https
  final double price;
  final bool available;
  final int order;

  const Dish({
    required this.id,
    required this.restaurantId,
    required this.section,
    this.note,
    required this.name,
    this.ingredients = const [],
    this.image,
    required this.price,
    this.available = true,
    required this.order,
  });

  factory Dish.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? <String, dynamic>{};
    final raw = m['ingredients'];
    // Anciens documents : les ingrédients étaient dans `desc`.
    final ing = raw is List
        ? raw.map((e) => '$e').toList()
        : splitIngredients(m['desc'] as String? ?? '');
    return Dish(
      id: d.id,
      restaurantId: m['restaurantId'] as String? ?? '',
      section: m['section'] as String? ?? '',
      note: m['note'] as String?,
      name: m['name'] as String? ?? '',
      ingredients: ing,
      image: m['image'] as String?,
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
        'ingredients': ingredients,
        'image': image,
        'price': price,
        'available': available,
        'order': order,
      };
}

/// Menu de départ (données locales), identique à ce que « Initialiser » enregistre.
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
        ingredients: splitIngredients(it.ingredients),
        image: it.photo ? 'assets/dishes/${r.id}_$n.jpg' : null,
        price: it.price,
        order: n,
      ));
      n++;
    }
  }
  return out;
}

/// Complète les plats de la base avec le menu local pour les restaurants pas encore initialisés.
List<Dish> mergeMenus(List<Dish> remote) {
  final have = <String>{for (final d in remote) d.restaurantId};
  final out = [...remote];
  for (final r in restaurants) {
    if (!have.contains(r.id)) {
      out.addAll(seedDishes(r));
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

/// Un restaurant dans Firestore (collection `restaurants`).
class RestoDoc {
  final String id;
  final String name;
  final int order;
  const RestoDoc({required this.id, required this.name, required this.order});

  factory RestoDoc.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? <String, dynamic>{};
    return RestoDoc(
      id: d.id,
      name: m['name'] as String? ?? d.id,
      order: (m['order'] as num?)?.toInt() ?? 99,
    );
  }
}

/// Noms et ordre venant de la base ; couleurs et icônes viennent de l'appli.
List<Restaurant> mergeRestos(List<RestoDoc> docs) {
  final byId = {for (final d in docs) d.id: d};
  final out = <MapEntry<int, Restaurant>>[];
  for (var i = 0; i < restaurants.length; i++) {
    final r = restaurants[i];
    final d = byId.remove(r.id);
    out.add(MapEntry(
      d?.order ?? i,
      Restaurant(r.id, d?.name ?? r.name, r.icon, r.color, r.sections),
    ));
  }
  for (final d in byId.values) {
    out.add(MapEntry(
      d.order,
      Restaurant(d.id, d.name, Icons.restaurant, kNavy, const <MenuSection>[]),
    ));
  }
  out.sort((a, b) => a.key.compareTo(b.key));
  return [for (final e in out) e.value];
}

/// Avis d'un client ayant commandé le plat (collection `reviews`).
class Review {
  final String id;
  final String dishId;
  final String dishName;
  final String restaurantId;
  final String userName;
  final String comment;
  final int rating;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.dishId,
    required this.dishName,
    required this.restaurantId,
    required this.userName,
    required this.comment,
    required this.rating,
    required this.createdAt,
  });

  factory Review.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? <String, dynamic>{};
    return Review(
      id: d.id,
      dishId: m['dishId'] as String? ?? '',
      dishName: m['dishName'] as String? ?? '',
      restaurantId: m['restaurantId'] as String? ?? '',
      userName: m['userName'] as String? ?? '',
      comment: m['comment'] as String? ?? '',
      rating: (m['rating'] as num?)?.toInt() ?? 0,
      createdAt: (m['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class Rating {
  final double avg;
  final int count;
  const Rating(this.avg, this.count);
}

Map<String, Rating> ratingsBy(List<Review> reviews, String Function(Review) key) {
  final sum = <String, int>{};
  final n = <String, int>{};
  for (final r in reviews) {
    final k = key(r);
    sum[k] = (sum[k] ?? 0) + r.rating;
    n[k] = (n[k] ?? 0) + 1;
  }
  return {for (final k in sum.keys) k: Rating(sum[k]! / n[k]!, n[k]!)};
}

class OrderLine {
  final String dishId;
  final String name;
  final double price;
  final int qty;
  const OrderLine({
    required this.dishId,
    required this.name,
    required this.price,
    required this.qty,
  });
}

/// Une commande (collection `orders`). status : pending -> validated -> ready
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
          dishId: x['dishId'] as String? ?? '',
          name: x['name'] as String? ?? '',
          price: (x['price'] as num?)?.toDouble() ?? 0,
          qty: (x['qty'] as num?)?.toInt() ?? 1,
        );
      }).toList(),
    );
  }
}
