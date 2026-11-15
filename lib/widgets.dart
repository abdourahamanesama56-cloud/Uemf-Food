import 'package:flutter/material.dart';

import 'l10n.dart';
import 'models.dart';
import 'theme.dart';

/// Image d'un plat : asset local ou lien https, avec un repli si elle manque.
class DishImage extends StatelessWidget {
  final String? path;
  final Color color;
  final double? width;
  final double? height;

  const DishImage({
    super.key,
    required this.path,
    required this.color,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final p = path;
    final placeholder = ColoredBox(
      color: color.withValues(alpha: 0.12),
      child: Center(
        child: Icon(Icons.restaurant, color: color.withValues(alpha: 0.5)),
      ),
    );
    final Widget child;
    if (p == null || p.isEmpty) {
      child = placeholder;
    } else if (p.startsWith('http')) {
      child = Image.network(
        p,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => placeholder,
      );
    } else {
      child = Image.asset(
        p,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => placeholder,
      );
    }
    return SizedBox(width: width, height: height, child: child);
  }
}

/// Étoile + note moyenne + nombre d'avis.
class RatingLabel extends StatelessWidget {
  final Rating? rating;
  const RatingLabel({super.key, this.rating});

  @override
  Widget build(BuildContext context) {
    final r = rating;
    if (r == null || r.count == 0) {
      return Text(
        lang.t('noReviews'),
        style: const TextStyle(fontSize: 12, color: Colors.black45),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star, size: 15, color: kGold),
        const SizedBox(width: 3),
        Text(
          '${r.avg.toStringAsFixed(1)} (${r.count})',
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
