import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

/// Base card matching the v2 HTML `.card` CSS
class BmCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;
  final Color? borderColor;

  const BmCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.borderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 12),
      padding: padding ?? const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color ?? (isDark ? Tok.card : Tok.cardLight),
        border: Border.all(color: borderColor ?? (isDark ? Tok.border : Tok.borderLight)),
        borderRadius: BorderRadius.circular(Tok.radius),
        boxShadow: isDark ? Tok.shadowCard : Tok.shadowCardLight,
      ),
      child: child,
    );
  }
}
