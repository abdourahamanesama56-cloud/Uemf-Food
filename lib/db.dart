import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'cart.dart';
import 'menu_data.dart';
import 'models.dart';

/// Accès Firestore : utilisateurs, menus, commandes.
class Db {
  static FirebaseFirestore get _f => FirebaseFirestore.instance;

  static Stream<DocumentSnapshot<Map<String, dynamic>>> userDoc(String uid) =>
      _f.collection('users').doc(uid).snapshots();

  // ---- Menus ----
  static Stream<List<Dish>> menu(String restaurantId) => _f
      .collection('menu_items')
      .where('restaurantId', isEqualTo: restaurantId)
      .snapshots()
      .map((s) => s.docs.map(Dish.fromDoc).toList());

  static Future<void> seedMenu(Restaurant r) async {
    final b = _f.batch();
    for (final d in seedDishes(r)) {
      b.set(_f.collection('menu_items').doc(d.id), d.toMap());
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
          {'name': l.dish.name, 'price': l.dish.price, 'qty': l.qty},
      ],
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
}
