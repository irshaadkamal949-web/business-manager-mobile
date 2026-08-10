import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

/// Section label with gold left-bar accent matching `.sec-label`
class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 10),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 12,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Tok.gold, Tok.gold2],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: isDark ? Tok.text3 : Tok.text3Light,
            ),
          ),
        ],
      ),
    );
  }
}

/// Badge chip matching `.badge-sold`, `.badge-credit`, etc.
class BadgeChip extends StatelessWidget {
  final String label;
  final Color color;

  const BadgeChip({Key? key, required this.label, required this.color}) : super(key: key);

  factory BadgeChip.cash() => const BadgeChip(label: 'CASH', color: Tok.green2);
  factory BadgeChip.credit() => const BadgeChip(label: 'CREDIT', color: Tok.teal2);
  factory BadgeChip.bank() => const BadgeChip(label: 'BANK', color: Tok.gold2);
  factory BadgeChip.warn(String t) => BadgeChip(label: t, color: Tok.red2);
  factory BadgeChip.left(String t) => BadgeChip(label: t, color: Tok.amber2);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        border: Border.all(color: color.withOpacity(0.25)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

/// Custom segmented tab bar matching `.tabs`
class BmTabBar extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const BmTabBar({
    Key? key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? Tok.card : Tok.cardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Tok.border : Tok.borderLight),
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final active = i == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: active ? (isDark ? Tok.card2 : Tok.card3Light) : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  border: active ? Border.all(color: isDark ? Tok.border2 : Tok.border2Light) : null,
                  boxShadow: active
                      ? [const BoxShadow(color: Color(0x40000000), blurRadius: 6, offset: Offset(0, 2))]
                      : null,
                ),
                child: Text(
                  tabs[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: active ? Tok.gold : (isDark ? Tok.text3 : Tok.text3Light),
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Confirmation dialog matching `.confirm-overlay`
class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final VoidCallback onConfirm;

  const ConfirmDialog({
    Key? key,
    required this.title,
    required this.message,
    this.confirmText = 'Yes, Delete',
    required this.onConfirm,
  }) : super(key: key);

  static Future<bool?> show(BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Yes, Delete',
  }) {
    return showDialog<bool>(
      context: context,
      barrierColor: const Color(0xCC050A14),
      builder: (ctx) => ConfirmDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        onConfirm: () => Navigator.pop(ctx, true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? Tok.bg2 : Tok.cardLight,
          border: Border.all(color: isDark ? Tok.border2 : Tok.border2Light),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Color(0x99000000), blurRadius: 60, offset: Offset(0, 20))],
        ),
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🗑️', style: TextStyle(fontSize: 32)),
              const SizedBox(height: 12),
              Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: isDark ? Tok.text : Tok.textLight), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(message, style: TextStyle(fontSize: 12, color: isDark ? Tok.text3 : Tok.text3Light, height: 1.6), textAlign: TextAlign.center),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Tok.gold.withOpacity(0.25)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text('Cancel', style: TextStyle(color: Tok.gold, fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Tok.red,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(confirmText, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// P&L row matching `.pl-row`
class PlRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;
  final bool total;
  final bool italic;

  const PlRow({
    Key? key,
    required this.label,
    required this.value,
    this.valueColor,
    this.bold = false,
    this.total = false,
    this.italic = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fs = total ? 14.0 : (italic ? 11.0 : 12.5);
    return Container(
      padding: EdgeInsets.symmetric(vertical: total ? 10 : 6),
      decoration: BoxDecoration(
        border: Border(
          top: total ? BorderSide(color: Tok.gold, width: 2) : BorderSide.none,
          bottom: total ? BorderSide.none : BorderSide(color: (isDark ? Tok.border : Tok.borderLight).withOpacity(0.4)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: fs,
                fontWeight: (bold || total) ? FontWeight.w700 : FontWeight.w400,
                fontStyle: italic ? FontStyle.italic : FontStyle.normal,
                color: italic ? (isDark ? Tok.text3 : Tok.text3Light) : (isDark ? Tok.text : Tok.textLight),
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: fs,
              fontWeight: (bold || total) ? FontWeight.w700 : FontWeight.w600,
              color: valueColor ?? (isDark ? Tok.text : Tok.textLight),
            ),
          ),
        ],
      ),
    );
  }
}

/// Cash flow item matching `.cf-item`
class CfItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isIn;
  final bool isTotal;

  const CfItem({Key? key, required this.label, required this.value, this.isIn = true, this.isTotal = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.symmetric(vertical: isTotal ? 10 : 7),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: (isDark ? Tok.border : Tok.borderLight).withOpacity(isTotal ? 0 : 0.35)),
          top: isTotal ? BorderSide(color: isDark ? Tok.border2 : Tok.border2Light) : BorderSide.none,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isTotal ? 13 : 12,
                fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
                color: isTotal ? (isDark ? Tok.text : Tok.textLight) : (isDark ? Tok.text : Tok.textLight),
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 15 : 12,
              fontWeight: FontWeight.w700,
              color: isIn ? Tok.green2 : Tok.red2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Aging bucket card matching `.aging-bucket`
class AgingBucket extends StatelessWidget {
  final String value;
  final String label;
  final Color? valueColor;

  const AgingBucket({Key? key, required this.value, required this.label, this.valueColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? Tok.card : Tok.cardLight,
        border: Border.all(color: isDark ? Tok.border : Tok.borderLight),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: valueColor ?? (isDark ? Tok.text : Tok.textLight), fontFamily: 'serif')),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 9, color: isDark ? Tok.text3 : Tok.text3Light, height: 1.4), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
