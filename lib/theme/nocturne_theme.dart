import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens transcribed from the design handoff's
/// `tokens/nocturne-styles.css` — dark, low-chroma, single accent used as
/// line/tint/glow, never a flood. Keep every screen sourcing colors/spacing
/// from here rather than hard-coding hexes.
class NocturneColors {
  NocturneColors._();

  static const bg = Color(0xFF161826);
  static const page = Color(0xFF10121C);
  static const surface = Color(0xFF232532);
  static const surface2 = Color(0xFF1E2030);
  static const surface3 = Color(0xFF1B1D2A);
  static const text = Color(0xFFE9E9ED);

  static const border = Color(0xFF3F424D);
  static const border2 = Color(0xFF2F3242);
  static const border3 = Color(0xFF595D6C);

  static const accent = Color(0xFF9184D9);
  static const accent100 = Color(0xFFF5F4FF);
  static const accent200 = Color(0xFFE7E5FE);
  static const accent300 = Color(0xFFD2CEFD);
  static const accent400 = Color(0xFFB5ABFC);
  static const accent500 = Color(0xFF968AE0);
  static const accent600 = Color(0xFF796CBF);
  static const accent700 = Color(0xFF5D5294);
  static const accent800 = Color(0xFF423A6A);
  static const accent900 = Color(0xFF2B2741);

  static const accent2 = Color(0xFFA7A1DB);
  static const accent2_400 = Color(0xFFB5AFE8);
  static const accent2_700 = Color(0xFF5C5783);
  static const accent2_900 = Color(0xFF2B293A);

  static const neutral100 = Color(0xFFF3F5FE);
  static const neutral200 = Color(0xFFE4E7F5);
  static const neutral300 = Color(0xFFCFD3E5);
  static const neutral400 = Color(0xFFB2B6CA);
  static const neutral500 = Color(0xFF9397AB);
  static const neutral600 = Color(0xFF75798C);
  static const neutral700 = Color(0xFF595D6C);
  static const neutral800 = Color(0xFF3F424D);
  static const neutral900 = Color(0xFF292B31);

  static const section = Color(0xFF262A60);

  /// The brief's `rgba(145,132,217,.12)` accent tint used behind outlined
  /// primary buttons.
  static Color accentTint([double opacity = 0.12]) => accent.withValues(alpha: opacity);
}

class NocturneSpace {
  NocturneSpace._();

  static const s1 = 2.8;
  static const s2 = 5.6;
  static const s3 = 8.4;
  static const s4 = 11.2;
  static const s6 = 16.8;
  static const s8 = 22.4;

  /// Screen side padding / card gap / bottom safe offset used everywhere.
  static const side = 22.0;
  static const cardGap = 12.0;
  static const bottomSafe = 26.0;
}

class NocturneRadius {
  NocturneRadius._();

  static const sm = 4.0;
  static const md = 8.0;
  static const lg = 14.0;
}

ThemeData buildNocturneTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: NocturneColors.bg,
    fontFamily: GoogleFonts.inter().fontFamily,
    colorScheme: ColorScheme.fromSeed(
      seedColor: NocturneColors.accent,
      brightness: Brightness.dark,
      surface: NocturneColors.surface,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      foregroundColor: NocturneColors.text,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData(brightness: Brightness.dark).textTheme)
        .apply(bodyColor: NocturneColors.text, displayColor: NocturneColors.text),
    switchTheme: SwitchThemeData(
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? NocturneColors.accent
            : NocturneColors.border2,
      ),
      thumbColor: const WidgetStatePropertyAll(NocturneColors.bg),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
  );
  return base;
}
