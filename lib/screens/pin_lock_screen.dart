import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/design_tokens.dart';

class PinLockScreen extends StatefulWidget {
  final VoidCallback onUnlock;
  const PinLockScreen({Key? key, required this.onUnlock}) : super(key: key);

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> with SingleTickerProviderStateMixin {
  final List<int> _entered = [];
  String _error = '';
  String _pin = '1234';
  late AnimationController _shakeCtrl;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _loadPin();
  }

  Future<void> _loadPin() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('app_pin');
    if (stored != null && stored.length == 4) _pin = stored;
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _onKey(int n) {
    if (_entered.length >= 4) return;
    HapticFeedback.lightImpact();
    setState(() {
      _entered.add(n);
      _error = '';
    });
    if (_entered.length == 4) {
      Future.delayed(const Duration(milliseconds: 150), _checkPin);
    }
  }

  void _onDelete() {
    if (_entered.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() {
      _entered.removeLast();
      _error = '';
    });
  }

  void _checkPin() {
    if (_entered.join('') == _pin) {
      widget.onUnlock();
    } else {
      _shakeCtrl.forward(from: 0);
      HapticFeedback.heavyImpact();
      setState(() {
        _error = 'Incorrect PIN. Try again.';
        _entered.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Tok.bg,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Text('🔐', style: const TextStyle(fontSize: 40)),
                const SizedBox(height: 12),
                Text(
                  'HI-TECH & AL-KABEER',
                  style: GoogleFonts.fraunces(fontSize: 22, fontWeight: FontWeight.w600, color: Tok.gold2),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter PIN to unlock Business Manager',
                  style: TextStyle(fontSize: 12, color: Tok.text3),
                ),
                const SizedBox(height: 36),

                // Dots
                AnimatedBuilder(
                  animation: _shakeCtrl,
                  builder: (_, child) {
                    final offset = _shakeCtrl.isAnimating
                        ? 10 * (0.5 - _shakeCtrl.value).abs() * (_shakeCtrl.value > 0.5 ? -1 : 1)
                        : 0.0;
                    return Transform.translate(offset: Offset(offset, 0), child: child);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (i) {
                      final filled = i < _entered.length;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 14, height: 14,
                        margin: const EdgeInsets.symmetric(horizontal: 7),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: filled ? Tok.gold : Colors.transparent,
                          border: Border.all(color: filled ? Tok.gold : Tok.border2, width: 2),
                        ),
                      );
                    }),
                  ),
                ),

                // Error
                const SizedBox(height: 16),
                SizedBox(
                  height: 16,
                  child: Text(_error, style: const TextStyle(fontSize: 11, color: Tok.red2), textAlign: TextAlign.center),
                ),
                const SizedBox(height: 24),

                // Keypad
                SizedBox(
                  width: 220,
                  child: Column(
                    children: [
                      for (final row in [[1,2,3],[4,5,6],[7,8,9],[-1,0,-2]])
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: row.map((n) {
                              if (n == -1) return const Expanded(child: SizedBox(height: 52));
                              if (n == -2) {
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: _onDelete,
                                    child: Container(
                                      height: 52,
                                      decoration: BoxDecoration(
                                        color: Tok.card2,
                                        border: Border.all(color: Tok.border),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Center(
                                        child: Text('⌫', style: TextStyle(fontSize: 14, color: Tok.text3)),
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(right: row.indexOf(n) < 2 ? 10 : 0),
                                  child: _PinKey(digit: n, onTap: () => _onKey(n)),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                Text('Demo PIN: 1234', style: TextStyle(fontSize: 10, color: Tok.text4)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PinKey extends StatelessWidget {
  final int digit;
  final VoidCallback onTap;
  const _PinKey({required this.digit, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Tok.card2,
          border: Border.all(color: Tok.border, width: 1.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(
            '$digit',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Tok.text),
          ),
        ),
      ),
    );
  }
}
