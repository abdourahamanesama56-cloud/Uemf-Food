import 'package:flutter/material.dart';

/// Plat du menu local (menu de départ). `ingredients` : liste séparée par des virgules.
class MenuItem {
  final String name;
  final double price;
  final String ingredients;
  final bool photo;
  const MenuItem(this.name, this.price, [this.ingredients = '', this.photo = true]);
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

List<String> splitIngredients(String s) => s
    .split(RegExp(r'[,+]'))
    .map((e) => e.trim())
    .where((e) => e.isNotEmpty)
    .toList();

/// Minuscules sans accents, pour la recherche.
String fold(String s) {
  const a = 'àâäáãéèêëíìîïóòôöõúùûüçñ';
  const b = 'aaaaaeeeeiiiiooooouuuucn';
  final sb = StringBuffer();
  for (final c in s.toLowerCase().split('')) {
    final i = a.indexOf(c);
    sb.write(i >= 0 ? b[i] : c);
  }
  return sb.toString();
}

const restaurants = <Restaurant>[
  Restaurant('pizza', 'Pizza', Icons.local_pizza, Color(0xFFC8541A), [
    MenuSection('Pizzas', [
      MenuItem('Pizza Margarita', 29, 'Sauce tomate, mozzarella, basilic, olives'),
      MenuItem('Pizza Végétarienne', 29,
          'Sauce tomate, mozzarella, poivrons, champignons, oignons, olives'),
      MenuItem('Pizza Peperoni', 32, 'Sauce tomate, mozzarella, pepperoni, olives'),
      MenuItem('Pizza Poulet', 36,
          'Sauce tomate, mozzarella, poulet, poivrons, olives'),
      MenuItem('Pizza Mixte', 38,
          'Sauce tomate, mozzarella, poulet, viande hachée, champignons, olives'),
      MenuItem('Pizza Bolognaise', 39,
          'Sauce tomate, mozzarella, viande hachée, oignons, olives'),
      MenuItem('Pizza au thon', 39, 'Sauce tomate, mozzarella, thon, oignons, olives'),
      MenuItem('Pizza Fruits de mer', 45,
          'Sauce tomate, mozzarella, crevettes, fruits de mer, olives'),
    ]),
  ]),
  Restaurant('asiatique', 'Cuisine Asiatique', Icons.ramen_dining,
      Color(0xFFB3261E), [
    MenuSection('Aromaki', note: '8 pièces', [
      MenuItem('Tokyo Salamon', 55, 'Saumon, avocat, surimi, crème cheese'),
      MenuItem('Tropical', 55, 'Saumon, surimi, crème cheese, ananas, mangue'),
      MenuItem('Ebi Maki', 45, 'Crevette, avocat, surimi, crème cheese'),
      MenuItem('Ocean Royal', 59, 'Crevette, saumon, surimi, crabe, crème cheese'),
    ]),
    MenuSection('Spéciaux', [
      MenuItem('Akinawa (5 pièces)', 32, 'Saumon, riz vinaigré, cheese'),
      MenuItem('Saumon Roll', 58, 'Saumon, avocat, riz vinaigré, cheese'),
      MenuItem('Saumon Brisé', 55, 'Saumon, crevette, mangue, riz vinaigré, cheese'),
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
      MenuItem('Chicken Burger', 28,
          'Pain burger, poulet pané, salade, tomate, sauce maison'),
      MenuItem('Cheese Burger', 29,
          'Pain burger, steak haché, fromage cheddar, salade, tomate, sauce maison'),
      MenuItem('Egg Burger', 32,
          'Pain burger, steak haché, œuf, fromage, salade, sauce maison'),
      MenuItem('Double Chicken Burger', 43,
          'Pain burger, double poulet pané, fromage, salade, sauce maison'),
      MenuItem('Double Cheese Burger', 44,
          'Pain burger, double steak haché, double fromage cheddar, salade, sauce maison'),
      MenuItem('Frites', 8, 'Pommes de terre, sel'),
    ]),
    MenuSection('Nos tacos', [
      MenuItem('Tacos Poulet', 29, 'Tortilla, poulet, frites, sauce fromagère'),
      MenuItem('Tacos Strips de poulet', 30,
          'Tortilla, strips de poulet, frites, sauce fromagère'),
      MenuItem('Tacos Viande hachée', 30,
          'Tortilla, viande hachée, frites, sauce fromagère'),
      MenuItem('Tacos Mixte', 32,
          'Tortilla, jambon fumé, poulet, viande hachée, frites, sauce fromagère'),
      MenuItem('Tacos Cordon bleu', 32,
          'Tortilla, cordon bleu, frites, sauce fromagère'),
    ]),
    MenuSection('Formules', [
      MenuItem('Formule Wrap', 42, 'Chicken wrap, frites, soda 25cl'),
      MenuItem('Formule Tacos', 42, 'Tacos, frites, soda 25cl'),
      MenuItem('Formule Cheese Burger', 43, 'Cheese burger, frites, soda 25cl'),
      MenuItem('Formule Egg Burger', 44, 'Egg burger, frites, soda 25cl'),
      MenuItem('Formule Double Chicken Burger', 54,
          'Double chicken burger, frites, soda'),
      MenuItem('Formule Double Cheese', 55,
          'Double cheese burger, frites, soda 25cl'),
    ]),
  ]),
  Restaurant('chawarma', 'Chawarma', Icons.kebab_dining, Color(0xFF8A4B2A), [
    MenuSection('Plats', [
      MenuItem('Chawarma Poulet Classic', 29, 'Pain, chawarma de poulet, sauce'),
      MenuItem('Kabsa Chawarma Bowl', 39, 'Chawarma, kabsa, sauce'),
      MenuItem('Chawarma Plat Arabi', 45, 'Chawarma, frites, salade'),
      MenuItem('Chawarma Box', 48, 'Chawarma, frites, strips, sauce'),
      MenuItem('Box Chicken Crespy', 45, 'Poulet crespy, riz, frites'),
      MenuItem('Poulet rôti 1/4', 32, 'Poulet rôti, riz, frites'),
      MenuItem('Poulet rôti 1/2', 62, 'Poulet rôti, riz, frites'),
      MenuItem('Formule 1 poulet rôti', 115,
          'Poulet rôti entier, frites, riz, soda 1 litre'),
    ]),
    MenuSection('Formules', [
      MenuItem('Formule Chawarma Classic', 39, 'Chawarma classic, frites, soda 25cl'),
      MenuItem('Formule Chawarma Box', 52,
          'Chawarma box, frites, strips, sauce, soda 25cl'),
    ]),
    MenuSection('Suppléments', [
      MenuItem('Sauce', 2, 'Sauce', false),
      MenuItem('1 strips de poulet', 9, 'Strips de poulet'),
      MenuItem('1 pièce de pilon de poulet', 9, 'Pilon de poulet'),
      MenuItem('Kabsa', 10, 'Kabsa'),
    ]),
  ]),
  Restaurant('salade', 'Bar à Salade', Icons.eco, Color(0xFF3E7D3A), [
    MenuSection('Céréales & bases', [
      MenuItem('Riz 100 g', 7, 'Riz'),
      MenuItem('Pâte penne 100 g', 7, 'Pâtes penne'),
      MenuItem('Ebly 100 g', 7, 'Ebly (blé)'),
      MenuItem('Quinoa 50 g', 7, 'Quinoa'),
    ]),
    MenuSection('Légumes crus', [
      MenuItem('Tomate 50 g', 2, 'Tomate'),
      MenuItem('Concombre 50 g', 2, 'Concombre'),
      MenuItem('Betterave 50 g', 2, 'Betterave'),
      MenuItem('Salade verte 30 g', 2, 'Salade verte'),
      MenuItem('Olive 50 g', 3, 'Olives noires'),
      MenuItem('Cornichon 50 g', 3, 'Cornichons'),
      MenuItem('Carotte 50 g', 3, 'Carotte râpée'),
    ]),
    MenuSection('Légumes & protéines', [
      MenuItem('PDT 50 g', 2, 'Pommes de terre'),
      MenuItem('Oignon 50 g', 2, 'Oignon'),
      MenuItem('Choux 50 g', 2, 'Chou'),
      MenuItem('Poivron 50 g', 2, 'Poivron'),
      MenuItem('Tomate cerise 50 g', 2, 'Tomates cerises'),
      MenuItem('Haricot vert 50 g', 2, 'Haricots verts'),
      MenuItem('Maïs 50 g', 5, 'Maïs'),
      MenuItem('Pois chiche 50 g', 5, 'Pois chiches'),
      MenuItem('Avocat 50 g', 7, 'Avocat'),
    ]),
    MenuSection('Protéines', [
      MenuItem('Poulet grillé 50 g', 8, 'Poulet grillé'),
      MenuItem('Poulet strips 50 g', 8, 'Strips de poulet'),
      MenuItem('Filet de thon 50 g', 9, 'Filet de thon'),
      MenuItem('Œuf dur (1 pièce)', 2.5, 'Œuf'),
    ]),
    MenuSection('Fromages', [
      MenuItem('Fromage mozzarella 50 g', 6, 'Mozzarella'),
      MenuItem('Fromage edam 50 g', 9, 'Edam'),
    ]),
    MenuSection('Fruits', [
      MenuItem('Orange 50 g', 3, 'Orange'),
      MenuItem('Banane 50 g', 5, 'Banane'),
      MenuItem('Kiwi 50 g', 5, 'Kiwi'),
      MenuItem('Mangue 50 g', 7, 'Mangue'),
      MenuItem('Fraise', 7, 'Fraises'),
      MenuItem('Ananas 50 g', 7, 'Ananas'),
      MenuItem('Raisins secs 50 g', 6, 'Raisins secs'),
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
