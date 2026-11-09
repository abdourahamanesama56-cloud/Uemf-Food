import 'package:flutter/material.dart';

import 'l10n.dart';

// Bleu université + terracotta/épices de cuisine + crème de table.
const kNavy = Color(0xFF14305C);
const kTerracotta = Color(0xFFC8541A);
const kCream = Color(0xFFFFF6E9);

ThemeData buildTheme() {
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: kNavy.withValues(alpha: 0.25)),
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: kNavy,
      primary: kNavy,
      secondary: kTerracotta,
      surface: kCream,
    ),
    scaffoldBackgroundColor: kCream,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: const BorderSide(color: kNavy, width: 2),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: kTerracotta,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}

/// Sélecteur FR / EN.
class LangSwitch extends StatelessWidget {
  const LangSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: lang,
      builder: (context, _) => SegmentedButton<String>(
        showSelectedIcon: false,
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: kNavy,
          selectedForegroundColor: Colors.white,
          visualDensity: VisualDensity.compact,
        ),
        segments: const [
          ButtonSegment(value: 'fr', label: Text('FR')),
          ButtonSegment(value: 'en', label: Text('EN')),
        ],
        selected: {lang.code},
        onSelectionChanged: (s) => lang.setCode(s.first),
      ),
    );
  }
}
