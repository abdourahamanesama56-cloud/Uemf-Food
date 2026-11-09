import 'package:flutter/material.dart';

class MenuItem {
  final String name;
  final double price;
  final String? desc;
  const MenuItem(this.name, this.price, [this.desc]);

  Map<String, dynamic> toMap() => {'name': name, 'price': price, 'desc': desc};
}

class MenuSection {
  final String title;
  final String? note;
  final List<MenuItem> items;
  const MenuSection(this.title, this.items, {this.note});
}

class Restaurant {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final List<MenuSection> sections;
  const Restaurant(this.id, this.name, this.icon, this.color, this.sections);

  int get count => sections.fold(0, (n, s) => n + s.items.length);

  String get image => 'assets/images/$id.jpg';
}

String formatPrice(double p) {
  final s = p == p.roundToDouble()
      ? p.toStringAsFixed(0)
      : p.toStringAsFixed(1).replaceAll('.', ',');
  return '$s DH';
}

const restaurants = <Restaurant>[
  Restaurant('pizza', 'Pizza', Icons.local_pizza, Color(0xFFC8541A), [
    MenuSection('Pizzas', [
      MenuItem('Pizza Margarita', 29),
      MenuItem('Pizza Végétarienne', 29),
      MenuItem('Pizza Peperoni', 32),
      MenuItem('Pizza Poulet', 36),
      MenuItem('Pizza Mixte', 38),
      MenuItem('Pizza Bolognaise', 39),
      MenuItem('Pizza au thon', 39),
      MenuItem('Pizza Fruits de mer', 45),
    ]),
  ]),
  Restaurant('asiatique', 'Cuisine Asiatique', Icons.ramen_dining,
      Color(0xFFB3261E), [
    MenuSection('Aromaki', note: '8 pièces', [
      MenuItem('Tokyo Salamon', 55, 'Saumon, avocat, surimi, crème cheese'),
      MenuItem('Tropical', 55,
          'Saumon, surimi, crème cheese, ananas, mangue'),
      MenuItem('Ebi Maki', 45, 'Crevette, avocat, surimi, crème cheese'),
      MenuItem('Ocean Royal', 59,
          'Crevette, saumon, surimi, crabe, crème cheese'),
    ]),
    MenuSection('Spéciaux', [
      MenuItem('Akinawa (5 pièces)', 32, 'Saumon, riz vinaigré, cheese'),
      MenuItem('Saumon Roll', 58, 'Saumon, avocat, riz vinaigré, cheese'),
      MenuItem('Saumon Brisé', 55,
          'Saumon, crevette, mangue, riz vinaigré, cheese'),
    ]),
    MenuSection('Crispy', note: '4 pièces', [
      MenuItem('Crispy Saumon', 28, 'Saumon, riz vinaigré, cheese'),
      MenuItem('Crispy Crabe', 25, 'Crabe, surimi, riz vinaigré, cheese'),
      MenuItem('Crispy Chaki Yaki', 28, 'Saumon, riz vinaigré, cheese'),
    ]),
    MenuSection('Nigiri', note: '2 pièces', [
      MenuItem('Nigiri Saumon', 15, 'Saumon, riz vinaigré'),
      MenuItem('Nigiri Crevette', 20, 'Crevette, riz vinaigré'),
    ]),
    MenuSection('Maki', note: '6 pièces', [
      MenuItem('Maki Concombre', 13, 'Concombre, cheese, riz vinaigré'),
      MenuItem('Maki Avocat', 16, 'Avocat, cheese, riz vinaigré'),
      MenuItem('Maki Surimi', 18, 'Surimi, cheese, riz vinaigré'),
      MenuItem('Maki Saumon', 26, 'Saumon, cheese, riz vinaigré'),
    ]),
  ]),
  Restaurant('hamburgerie', 'Hamburgerie', Icons.lunch_dining,
      Color(0xFFC98A0B), [
    MenuSection('Nos burgers', [
      MenuItem('Chicken Burger', 28),
      MenuItem('Cheese Burger', 29),
      MenuItem('Egg Burger', 32),
      MenuItem('Double Chicken Burger', 43),
      MenuItem('Double Cheese Burger', 44),
      MenuItem('Frites', 8),
    ]),
    MenuSection('Nos tacos', [
      MenuItem('Tacos Poulet', 29),
      MenuItem('Tacos Strips de poulet', 30),
      MenuItem('Tacos Viande hachée', 30),
      MenuItem('Tacos Mixte', 32, 'Jambon fumé, poulet, viande hachée'),
      MenuItem('Tacos Cordon bleu', 32),
    ]),
    MenuSection('Formules', [
      MenuItem('Formule Wrap', 42, 'Chicken wrap + frites + soda 25cl'),
      MenuItem('Formule Tacos', 42, 'Tacos + frites + soda 25cl'),
      MenuItem('Formule Cheese Burger', 43,
          'Cheese burger + frites + soda 25cl'),
      MenuItem('Formule Egg Burger', 44, 'Egg burger + frites + soda 25cl'),
      MenuItem('Formule Double Chicken Burger', 54,
          'Double chicken burger + frites + soda'),
      MenuItem('Formule Double Cheese', 55,
          'Double cheese burger + frites + soda 25cl'),
    ]),
  ]),
  Restaurant('chawarma', 'Chawarma', Icons.kebab_dining, Color(0xFF8A4B2A), [
    MenuSection('Plats', [
      MenuItem('Chawarma Poulet Classic', 29, 'Sandwich chawarma'),
      MenuItem('Kabsa Chawarma Bowl', 39, 'Chawarma + kabsa + sauce'),
      MenuItem('Chawarma Plat Arabi', 45, 'Chawarma + frites + salade'),
      MenuItem('Chawarma Box', 48, 'Chawarma + frites + strips + sauce'),
      MenuItem('Box Chicken Crespy', 45, 'Poulet crespy + riz + frites'),
      MenuItem('Poulet rôti 1/4', 32, 'Riz + frites'),
      MenuItem('Poulet rôti 1/2', 62, 'Riz + frites'),
      MenuItem('Formule 1 poulet rôti', 115,
          'Poulet entier + frites + riz + soda 1 litre'),
    ]),
    MenuSection('Formules', [
      MenuItem('Formule Chawarma Classic', 39, 'Frites + soda 25cl'),
      MenuItem('Formule Chawarma Box', 52,
          'Frites + strips + sauce + soda 25cl'),
    ]),
    MenuSection('Suppléments', [
      MenuItem('Sauce', 2),
      MenuItem('1 strips de poulet', 9),
      MenuItem('1 pièce de pilon de poulet', 9),
      MenuItem('Kabsa', 10),
    ]),
  ]),
  Restaurant('salade', 'Bar à Salade', Icons.eco, Color(0xFF3E7D3A), [
    MenuSection('Céréales & bases', [
      MenuItem('Riz 100 g', 7),
      MenuItem('Pâte penne 100 g', 7),
      MenuItem('Ebly 100 g', 7),
      MenuItem('Quinoa 50 g', 7),
    ]),
    MenuSection('Légumes crus', [
      MenuItem('Tomate 50 g', 2),
      MenuItem('Concombre 50 g', 2),
      MenuItem('Betterave 50 g', 2),
      MenuItem('Salade verte 30 g', 2),
      MenuItem('Olive 50 g', 3),
      MenuItem('Cornichon 50 g', 3),
      MenuItem('Carotte 50 g', 3),
    ]),
    MenuSection('Légumes & protéines', [
      MenuItem('PDT 50 g', 2),
      MenuItem('Oignon 50 g', 2),
      MenuItem('Choux 50 g', 2),
      MenuItem('Poivron 50 g', 2),
      MenuItem('Tomate cerise 50 g', 2),
      MenuItem('Haricot vert 50 g', 2),
      MenuItem('Maïs 50 g', 5),
      MenuItem('Pois chiche 50 g', 5),
      MenuItem('Avocat 50 g', 7),
    ]),
    MenuSection('Protéines', [
      MenuItem('Poulet grillé 50 g', 8),
      MenuItem('Poulet strips 50 g', 8),
      MenuItem('Filet de thon 50 g', 9),
      MenuItem('Œuf dur (1 pièce)', 2.5),
    ]),
    MenuSection('Fromages', [
      MenuItem('Fromage mozzarella 50 g', 6),
      MenuItem('Fromage edam 50 g', 9),
    ]),
    MenuSection('Fruits', [
      MenuItem('Orange 50 g', 3),
      MenuItem('Banane 50 g', 5),
      MenuItem('Kiwi 50 g', 5),
      MenuItem('Mangue 50 g', 7),
      MenuItem('Fraise', 7),
      MenuItem('Ananas 50 g', 7),
      MenuItem('Raisins secs 50 g', 6),
    ]),
    MenuSection('Bol énergie', [
      MenuItem('Bol énergie', 16,
          'Flocons d’avoine, riz, ebly, graines de lin, raisins, banane, raisins secs, miel'),
    ]),
  ]),
];

Restaurant? restaurantById(String? id) {
  for (final r in restaurants) {
    if (r.id == id) return r;
  }
  return null;
}
