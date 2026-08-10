import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/design_tokens.dart';

enum KpiAccent { gold, red, green, teal, none }

/// KPI card with colored top accent bar matching v2 HTML `.kpi-card`
class KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final String? delta;
  final bool deltaUp;
  final KpiAccent accent;
  final Color? valueColor;

  const KpiCard({
    Key? key,
    required this.title,
    required this.value,
    this.subtitle,
    this.delta,
    this.deltaUp = true,
    this.accent = KpiAccent.none,
    this.valueColor,
  }) : super(key: key);

  Color _accentColor() {
    switch (accent) {
      case KpiAccent.gold: return Tok.gold;
      case KpiAccent.red: return Tok.red;
      case KpiAccent.green: return Tok.green;
      case KpiAccent.teal: return Tok.teal;
      case KpiAccent.none: return Tok.border2;
    }
  }

  Color _accentColor2() {
    switch (accent) {
      case KpiAccent.gold: return Tok.gold2;
      case KpiAccent.red: return Tok.red2;
      case KpiAccent.green: return Tok.green2;
      case KpiAccent.teal: return Tok.teal2;
      case KpiAccent.none: return Tok.border2;
    }
  }

  Color _valueClr() {
    if (valueColor != null) return valueColor!;
    switch (accent) {
      case KpiAccent.gold: return Tok.gold2;
      case KpiAccent.red: return Tok.red2;
      case KpiAccent.green: return Tok.green2;
      case KpiAccent.teal: return Tok.teal2;
      case KpiAccent.none: return Tok.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Tok.card : Tok.cardLight,
        border: Border.all(color: isDark ? Tok.border : Tok.borderLight),
        borderRadius: BorderRadius.circular(Tok.radius),
        boxShadow: isDark ? Tok.shadowCard : Tok.shadowCardLight,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top accent bar
          Container(
            height: 2.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [_accentColor(), _accentColor2()]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.9,
                    color: isDark ? Tok.text3 : Tok.text3Light,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  value,
                  style: GoogleFonts.fraunces(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: _valueClr(),
                    height: 1,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 5),
                  Text(subtitle!, style: TextStyle(fontSize: 10, color: isDark ? Tok.text3 : Tok.text3Light)),
                ],
                if (delta != null) ...[
                  const SizedBox(height: 5),
                  Text(
                    delta!,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: deltaUp ? Tok.green2 : Tok.red2,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
