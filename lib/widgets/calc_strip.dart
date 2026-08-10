import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/design_tokens.dart';

/// Live calculation strip matching v2 HTML `.calc-strip`
class CalcStrip extends StatelessWidget {
  final String label;
  final String? sublabel;
  final String value;
  final bool negative;

  const CalcStrip({
    Key? key,
    required this.label,
    this.sublabel,
    required this.value,
    this.negative = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? Tok.card3 : Tok.card3Light,
        border: Border.all(color: isDark ? Tok.border2 : Tok.border2Light),
        borderRadius: BorderRadius.circular(Tok.radiusSm),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(fontSize: 10, color: isDark ? Tok.text3 : Tok.text3Light, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                ),
                if (sublabel != null) ...[
                  const SizedBox(height: 2),
                  Text(sublabel!, style: TextStyle(fontSize: 10, color: isDark ? Tok.text3 : Tok.text3Light)),
                ],
              ],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.fraunces(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: negative ? Tok.red2 : Tok.gold2,
            ),
          ),
        ],
      ),
    );
  }
}
