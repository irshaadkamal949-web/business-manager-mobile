import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';
import '../widgets/tile_button.dart';
import 'farm/farm_sales_screen.dart';
import 'farm/farm_payments_screen.dart';
import 'farm/farm_purchases_screen.dart';
import 'farm/farm_expenses_screen.dart';
import 'farm/farm_inventory_screen.dart';
import 'farm/farm_dashboard_screen.dart';
import '../db/database_helper.dart';
import 'package:intl/intl.dart';

class FarmTab extends StatefulWidget {
  const FarmTab({Key? key}) : super(key: key);

  @override
  State<FarmTab> createState() => _FarmTabState();
}

class _FarmTabState extends State<FarmTab> {
  final _db = DatabaseHelper.instance;
  int _salesCount = 0;
  int _goats = 0;
  double _outstanding = 0;
  int _batches = 0;
  double _expenses = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final now = DateTime.now();
    final monthStart = DateFormat('yyyy-MM').format(now) + '-01';

    final sStats = await _db.getFarmSalesStats(monthStart: monthStart);
    final goats = await _db.getGoatsInStock();
    final out = await _db.getFarmOutstanding();
    final b = await _db.getDashboardStats();
    final exp = await _db.getFarmExpensesTotal(monthStart: monthStart);

    if (mounted) {
      setState(() {
        _salesCount = (sStats['totalCount'] ?? 0).toInt();
        _goats = goats;
        _outstanding = out;
        _batches = (b['activeBatches'] ?? 0).toInt();
        _expenses = exp;
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
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: Tok.gold));
    }
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
                  icon: '💸', name: 'Sales & Returns',
                  count: '$_salesCount sales this month',
                  onTap: () => _nav(const FarmSalesScreen()),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: TileButton(
                  icon: '📥', name: 'Payment Receiving',
                  count: '${_fmt(_outstanding)} pending',
                  onTap: () => _nav(const FarmPaymentsScreen()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TileButton(
                  icon: '🐐', name: 'Purchases / Suppliers',
                  count: '$_batches active batches',
                  onTap: () => _nav(const FarmPurchasesScreen()),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: TileButton(
                  icon: '📉', name: 'Farm Expenses',
                  count: '${_fmt(_expenses)} this month',
                  onTap: () => _nav(const FarmExpensesScreen()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TileButton(
                  icon: '📦', name: 'Inventory / Stock Out',
                  count: '$_goats live goats',
                  onTap: () => _nav(const FarmInventoryScreen()),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: TileButton(
                  icon: '📊', name: 'Farm Dashboard',
                  count: 'Reports & trends',
                  onTap: () => _nav(const FarmDashboardScreen()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
