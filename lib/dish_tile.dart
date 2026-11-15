import 'package:flutter/material.dart';

import 'cart.dart';
import 'dish_page.dart';
import 'l10n.dart';
import 'menu_data.dart';
import 'models.dart';
import 'theme.dart';
import 'widgets.dart';

/// Ligne de plat façon Glovo : texte à gauche, photo + bouton « + » à droite.
class DishTile extends StatelessWidget {
  final Dish dish;
  final Color color;
  final Rating? rating;
  final String? restoName;
  final bool showResto;

  const DishTile({
    super.key,
    required this.dish,
    required this.color,
    this.rating,
    this.restoName,
    this.showResto = false,
  });

  @override
  Widget build(BuildContext context) {
    final off = !dish.available;
    final name = restoName;
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              DishPage(dish: dish, color: color, restoName: restoName),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dish.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15.5,
                      color: off ? Colors.grey : kNavy,
                      decoration: off ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (showResto && name != null)
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 12,
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  if (dish.ingredients.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        dish.ingredients.join(', '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  const SizedBox(height: 6),
                  RatingLabel(rating: rating),
                  const SizedBox(height: 4),
                  Text(
                    formatPrice(dish.price),
                    style: const TextStyle(
                      color: kTerracotta,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 96,
              height: 96,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: DishImage(path: dish.image, color: color),
                    ),
                  ),
                  Positioned(
                    right: 4,
                    bottom: 4,
                    child: _AddControl(dish: dish),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddControl extends StatelessWidget {
  final Dish dish;
  const _AddControl({required this.dish});

  @override
  Widget build(BuildContext context) {
    final q = cart.qtyOf(dish.id);
    if (!dish.available) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          lang.t('soldOut'),
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFFB3261E),
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    if (q == 0) {
      return Material(
        color: Colors.white,
        elevation: 2,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => addToCart(context, dish),
          child: const Padding(
            padding: EdgeInsets.all(6),
            child: Icon(Icons.add, size: 20, color: kTerracotta),
          ),
        ),
      );
    }
    return Material(
      color: Colors.white,
      elevation: 2,
      borderRadius: BorderRadius.circular(20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => cart.remove(dish),
            child: const Padding(
              padding: EdgeInsets.all(5),
              child: Icon(Icons.remove, size: 18),
            ),
          ),
          Text('$q', style: const TextStyle(fontWeight: FontWeight.bold)),
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => addToCart(context, dish),
            child: const Padding(
              padding: EdgeInsets.all(5),
              child: Icon(Icons.add, size: 18, color: kTerracotta),
            ),
          ),
        ],
      ),
    );
  }
}
