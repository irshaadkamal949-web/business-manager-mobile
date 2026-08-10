import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/design_tokens.dart';
import '../widgets/tile_button.dart';
import 'shop/shop_daily_log_screen.dart';
import 'shop/shop_credit_screen.dart';
import 'shop/shop_dashboard_screen.dart';
import '../db/database_helper.dart';

class ShopTab extends StatefulWidget {
  const ShopTab({Key? key}) : super(key: key);
  @override
  State<ShopTab> createState() => _ShopTabState();
}

class _ShopTabState extends State<ShopTab> {
  final _db = DatabaseHelper.instance;
  bool _loading = true;
  int _days = 0;
  double _shopCredit = 0;
  double _profit = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final now = DateTime.now();
    final monthStart = DateFormat('yyyy-MM').format(now) + '-01';
    
    final s = await _db.getShopDailyStats(monthStart: monthStart);
    final e = await _db.getShopExpensesTotal(monthStart: monthStart);
    final c = await _db.getTotalShopCredit();

    if (mounted) {
      setState(() {
        _days = (s['days'] ?? 0).toInt();
        _shopCredit = c;
        _profit = (s['netProfit'] ?? 0) - e;
        _loading = false;
      });
    }
  }

  void _nav(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen)).then((_) => _load());
  }

  String _fmt(double v) => '₹${NumberFormat('#,##,###', 'en_IN').format(v.round())}';

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return RefreshIndicator(
      color: Tok.gold,
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          Row(
            children: [
              Expanded(
                child: TileButton(
                  icon: '📝', name: 'Daily Log',
                  count: '$_days days logged',
                  onTap: () => _nav(const ShopDailyLogScreen()),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: TileButton(
                  icon: '📒', name: 'Credit Recorder',
                  count: '${_fmt(_shopCredit)} out',
                  onTap: () => _nav(const ShopCreditScreen()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TileButton(
                  icon: '📊', name: 'Shop Dashboard',
                  count: '${_fmt(_profit)} profit',
                  onTap: () => _nav(const ShopDashboardScreen()),
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(child: SizedBox()), // Empty slot for alignment
            ],
          ),
        ],
      ),
    );
  }
}
