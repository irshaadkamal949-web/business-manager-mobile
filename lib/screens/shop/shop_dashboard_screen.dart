import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/design_tokens.dart';
import '../../widgets/bm_card.dart';
import '../../widgets/kpi_card.dart';
import '../../widgets/shared_widgets.dart';
import '../../widgets/chart_widgets.dart';
import '../../db/database_helper.dart';

class ShopDashboardScreen extends StatefulWidget {
  const ShopDashboardScreen({Key? key}) : super(key: key);
  @override
  State<ShopDashboardScreen> createState() => _ShopDashboardScreenState();
}

class _ShopDashboardScreenState extends State<ShopDashboardScreen> {
  final _db = DatabaseHelper.instance;
  bool _loading = true;

  double _sales = 0, _pur = 0, _exp = 0, _net = 0;
  List<String> _labels = [];
  List<double> _trendSale = [];
  List<double> _trendPur = [];
  List<double> _trendProfit = [];

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
    final t = await _db.getMonthlyProfitTrend(7);

    if (mounted) {
      setState(() {
        _pur = s['totalPurchases'] ?? 0;
        _sales = (s['netProfit'] ?? 0) + _pur; // Reconstructing total income for display
        _exp = e;
        _net = (s['netProfit'] ?? 0) - _exp;
        
        _labels = t.map((m) => m['label'] as String).toList();
        _trendSale = t.map((m) => (m['shopSales'] as num).toDouble()).toList();
        _trendPur = t.map((m) => (m['shopPurchases'] as num).toDouble()).toList();
        _trendProfit = t.map((m) => (m['shopProfit'] as num).toDouble()).toList();
        _loading = false;
      });
    }
  }

  String _fmt(double v) => '₹${NumberFormat('#,##,###', 'en_IN').format(v.round())}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shop Dashboard', style: TextStyle(fontSize: 15))),
      body: _loading ? const Center(child: CircularProgressIndicator()) : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(child: KpiCard(title: 'Shop Gross', value: _fmt(_sales - _pur), accent: KpiAccent.gold)),
              const SizedBox(width: 12),
              Expanded(child: KpiCard(title: 'Shop Net', value: _fmt(_net), accent: _net >= 0 ? KpiAccent.green : KpiAccent.red)),
            ],
          ),
          const SizedBox(height: 20),
          BmCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionLabel('Income vs Purchases'),
                TrendLineChart(
                  labels: _labels,
                  datasets: [_trendSale, _trendPur],
                  colors: [Tok.green2, Tok.red2],
                  legendLabels: const ['Income', 'Purchases'],
                ),
              ],
            ),
          ),
          BmCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionLabel('Net Profit Trend'),
                ProfitBarChart(labels: _labels, data: _trendProfit),
              ],
            ),
          ),
          BmCard(
            child: Column(
              children: [
                const SectionLabel('This Month Summary'),
                PlRow(label: 'Total Income', value: _fmt(_sales)),
                PlRow(label: 'Less: Purchases', value: _fmt(_pur), valueColor: Tok.red2),
                PlRow(label: 'Gross Profit', value: _fmt(_sales - _pur), bold: true),
                PlRow(label: 'Less: Expenses', value: _fmt(_exp), valueColor: Tok.red2),
                PlRow(label: 'Net Shop Profit', value: _fmt(_net), valueColor: _net >= 0 ? Tok.green2 : Tok.red2, total: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
