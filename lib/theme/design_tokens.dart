import 'package:flutter/material.dart';

/// All design tokens from the v2 HTML CSS :root variables
class Tok {
  Tok._();

  // ─── DARK PALETTE ───────────────────────────────────────
  static const Color bg = Color(0xFF0B1520);
  static const Color bg2 = Color(0xFF0F1D2E);
  static const Color card = Color(0xFF162030);
  static const Color card2 = Color(0xFF1C2B40);
  static const Color card3 = Color(0xFF213450);
  static const Color border = Color(0xFF263D58);
  static const Color border2 = Color(0xFF2F4C6E);
  static const Color border3 = Color(0xFF3A5F88);

  // ─── LIGHT PALETTE ──────────────────────────────────────
  static const Color bgLight = Color(0xFFF5F5F0);
  static const Color bg2Light = Color(0xFFEBEBE4);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color card2Light = Color(0xFFF8F8F3);
  static const Color card3Light = Color(0xFFF0F0EA);
  static const Color borderLight = Color(0xFFDDD8CC);
  static const Color border2Light = Color(0xFFCCC7BB);
  static const Color border3Light = Color(0xFFBBB5A8);

  // ─── GOLD — warm, premium ───────────────────────────────
  static const Color gold = Color(0xFFC8A44A);
  static const Color gold2 = Color(0xFFE2C272);
  static const Color gold3 = Color(0xFFF0D898);
  static const Color goldBg = Color(0x1AC8A44A); // 10%
  static const Color goldBorder = Color(0x40C8A44A); // 25%

  // ─── SEMANTIC COLORS ────────────────────────────────────
  static const Color teal = Color(0xFF1A9E78);
  static const Color teal2 = Color(0xFF22C49A);
  static const Color tealBg = Color(0x1A1A9E78);

  static const Color red = Color(0xFFD94F4F);
  static const Color red2 = Color(0xFFF07070);
  static const Color redBg = Color(0x1AD94F4F);

  static const Color green = Color(0xFF2AAE68);
  static const Color green2 = Color(0xFF48D48A);
  static const Color greenBg = Color(0x1A2AAE68);

  static const Color amber = Color(0xFFC8840A);
  static const Color amber2 = Color(0xFFF5A623);

  // ─── TEXT ───────────────────────────────────────────────
  static const Color text = Color(0xFFDDEAF7);
  static const Color text2 = Color(0xFF8FAFC8);
  static const Color text3 = Color(0xFF4F6D88);
  static const Color text4 = Color(0xFF3A526A);

  // Light theme text
  static const Color textLight = Color(0xFF1A1A1A);
  static const Color text2Light = Color(0xFF4A4A4A);
  static const Color text3Light = Color(0xFF7A7A7A);
  static const Color text4Light = Color(0xFFAAAAAA);

  // ─── RADII & SHADOWS ───────────────────────────────────
  static const double radius = 14.0;
  static const double radiusSm = 8.0;

  static const List<BoxShadow> shadow = [
    BoxShadow(color: Color(0x59000000), blurRadius: 8, offset: Offset(0, 2)),
    BoxShadow(color: Color(0x40000000), blurRadius: 24, offset: Offset(0, 8)),
  ];

  static const List<BoxShadow> shadowCard = [
    BoxShadow(color: Color(0x66000000), blurRadius: 3, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x4D000000), blurRadius: 20, offset: Offset(0, 6)),
  ];

  static const List<BoxShadow> shadowCardLight = [
    BoxShadow(color: Color(0x15000000), blurRadius: 4, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x08000000), blurRadius: 12, offset: Offset(0, 4)),
  ];
}
