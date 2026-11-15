import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'cart.dart';
import 'menu_data.dart';
import 'models.dart';

/// Accès Firestore : utilisateurs, restaurants, menus, commandes, avis.
class Db {
  static FirebaseFirestore get _f => FirebaseFirestore.instance;

  static Stream<DocumentSnapshot<Map<String, dynamic>>> userDoc(String uid) =>
      _f.collection('users').doc(uid).snapshots();

  // ---- Restaurants ----
  static Stream<List<RestoDoc>> restaurants() => _f
      .collection('restaurants')
      .snapshots()
      .map((s) => s.docs.map(RestoDoc.fromDoc).toList());

  // ---- Menus ----
  static Stream<List<Dish>> menu(String restaurantId) => _f
      .collection('menu_items')
      .where('restaurantId', isEqualTo: restaurantId)
      .snapshots()
      .map((s) => s.docs.map(Dish.fromDoc).toList());

  static Stream<List<Dish>> allMenu() => _f
      .collection('menu_items')
      .snapshots()
      .map((s) => s.docs.map(Dish.fromDoc).toList());

  static void _seedInto(WriteBatch b, Restaurant r) {
    b.set(_f.collection('restaurants').doc(r.id), {
      'name': r.name,
      'order': restaurantsList.indexOf(r),
    });
    for (final d in seedDishes(r)) {
      b.set(_f.collection('menu_items').doc(d.id), d.toMap());
    }
  }

  /// Enregistre un restaurant et tous ses plats (admin du restaurant).
  static Future<void> seedRestaurant(Restaurant r) async {
    final b = _f.batch();
    _seedInto(b, r);
    await b.commit();
  }

  /// Enregistre les 5 restaurants et tous leurs plats (compte owner).
  static Future<void> seedAll() async {
    final b = _f.batch();
    for (final r in restaurantsList) {
      _seedInto(b, r);
    }
    await b.commit();
  }

  static String newDishId() => _f.collection('menu_items').doc().id;

  static Future<void> saveDish(Dish d) =>
      _f.collection('menu_items').doc(d.id).set(d.toMap());

  static Future<void> setAvailable(Dish d, bool value) =>
      _f.collection('menu_items').doc(d.id).update({'available': value});

  static Future<void> deleteDish(Dish d) =>
      _f.collection('menu_items').doc(d.id).delete();

  // ---- Commandes ----
  static Future<void> placeOrder(Restaurant r, String note) {
    final u = FirebaseAuth.instance.currentUser!;
    return _f.collection('orders').add({
      'userId': u.uid,
      'userName': u.displayName ?? u.email ?? '',
      'restaurantId': r.id,
      'restaurantName': r.name,
      'items': [
        for (final l in cart.lines.values)
          {
            'dishId': l.dish.id,
            'name': l.dish.name,
            'price': l.dish.price,
            'qty': l.qty,
          },
      ],
      'dishIds': [for (final l in cart.lines.values) l.dish.id],
      'total': cart.total,
      'note': note.trim(),
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Stream<List<OrderDoc>> myOrders() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return _f
        .collection('orders')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map(_orders);
  }

  static Stream<List<OrderDoc>> restaurantOrders(String restaurantId) => _f
      .collection('orders')
      .where('restaurantId', isEqualTo: restaurantId)
      .snapshots()
      .map(_orders);

  /// Plus récentes d'abord.
  static List<OrderDoc> _orders(QuerySnapshot<Map<String, dynamic>> s) {
    final l = s.docs.map(OrderDoc.fromDoc).toList();
    l.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return l;
  }

  static Future<void> setStatus(String orderId, String status) =>
      _f.collection('orders').doc(orderId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

  // ---- Avis (clients ayant commandé le plat) ----
  static Stream<List<Review>> reviews({String? restaurantId, String? dishId}) {
    Query<Map<String, dynamic>> q = _f.collection('reviews');
    if (restaurantId != null) {
      q = q.where('restaurantId', isEqualTo: restaurantId);
    }
    if (dishId != null) {
      q = q.where('dishId', isEqualTo: dishId);
    }
    return q.snapshots().map((s) {
      final l = s.docs.map(Review.fromDoc).toList();
      l.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return l;
    });
  }

  static Future<void> addReview(
    OrderDoc o,
    OrderLine l,
    int rating,
    String comment,
  ) {
    final u = FirebaseAuth.instance.currentUser!;
    return _f.collection('reviews').doc('${o.id}_${l.dishId}').set({
      'orderId': o.id,
      'dishId': l.dishId,
      'dishName': l.name,
      'restaurantId': o.restaurantId,
      'userId': u.uid,
      'userName': u.displayName ?? '',
      'rating': rating,
      'comment': comment.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

/// Liste locale des restaurants (évite le conflit de nom avec `Db.restaurants`).
const restaurantsList = restaurants;
