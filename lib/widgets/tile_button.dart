import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

/// Navigation tile matching v2 HTML `.tile`
class TileButton extends StatelessWidget {
  final String icon;
  final String name;
  final String count;
  final VoidCallback onTap;
  final bool fullWidth;

  const TileButton({
    Key? key,
    required this.icon,
    required this.name,
    required this.count,
    required this.onTap,
    this.fullWidth = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Tok.card : Tok.cardLight,
          border: Border.all(color: isDark ? Tok.border : Tok.borderLight),
          borderRadius: BorderRadius.circular(Tok.radius),
          boxShadow: isDark ? Tok.shadowCard : Tok.shadowCardLight,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(icon, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 10),
            Text(name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Tok.text : Tok.textLight, letterSpacing: 0.1)),
            const SizedBox(height: 4),
            Text(count, style: TextStyle(fontSize: 10, color: isDark ? Tok.text3 : Tok.text3Light)),
          ],
        ),
      ),
    );
  }
}
