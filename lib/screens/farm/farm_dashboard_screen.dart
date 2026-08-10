import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/design_tokens.dart';
import '../../widgets/bm_card.dart';
import '../../widgets/kpi_card.dart';
import '../../widgets/shared_widgets.dart';
import '../../widgets/chart_widgets.dart';
import '../../db/database_helper.dart';

class FarmDashboardScreen extends StatefulWidget {
  const FarmDashboardScreen({Key? key}) : super(key: key);
  @override
  State<FarmDashboardScreen> createState() => _FarmDashboardScreenState();
}

class _FarmDashboardScreenState extends State<FarmDashboardScreen> {
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
    
    final s = await _db.getFarmSalesStats(monthStart: monthStart);
    final p = await _db.getFarmPurchaseCostMonth(monthStart: monthStart);
    final e = await _db.getFarmExpensesTotal(monthStart: monthStart);
    final t = await _db.getMonthlyProfitTrend(7);

    if (mounted) {
      setState(() {
        _sales = s['totalNet'] ?? 0;
        _pur = p;
        _exp = e;
        _net = _sales - _pur - _exp;
        
        _labels = t.map((m) => m['label'] as String).toList();
        _trendSale = t.map((m) => (m['farmSales'] as num).toDouble()).toList();
        _trendPur = t.map((m) => (m['farmPurchases'] as num).toDouble()).toList();
        _trendProfit = t.map((m) => (m['farmProfit'] as num).toDouble()).toList();
        _loading = false;
      });
    }
  }

  String _fmt(double v) => '₹${NumberFormat('#,##,###', 'en_IN').format(v.round())}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Farm Dashboard', style: TextStyle(fontSize: 15))),
      body: _loading ? const Center(child: CircularProgressIndicator()) : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(child: KpiCard(title: 'Farm Gross', value: _fmt(_sales - _pur), accent: KpiAccent.gold)),
              const SizedBox(width: 12),
              Expanded(child: KpiCard(title: 'Farm Net', value: _fmt(_net), accent: _net >= 0 ? KpiAccent.green : KpiAccent.red)),
            ],
          ),
          const SizedBox(height: 20),
          BmCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionLabel('Sales vs Purchases'),
                TrendLineChart(
                  labels: _labels,
                  datasets: [_trendSale, _trendPur],
                  colors: [Tok.green2, Tok.red2],
                  legendLabels: const ['Sales', 'Purchases'],
                ),
              ],
            ),
          ),
          BmCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionLabel('Gross Profit Trend'),
                ProfitBarChart(labels: _labels, data: _trendProfit),
              ],
            ),
          ),
          BmCard(
            child: Column(
              children: [
                const SectionLabel('This Month Summary'),
                PlRow(label: 'Total Sales', value: _fmt(_sales)),
                PlRow(label: 'Less: Purchases', value: _fmt(_pur), valueColor: Tok.red2),
                PlRow(label: 'Gross Profit', value: _fmt(_sales - _pur), bold: true),
                PlRow(label: 'Less: Expenses', value: _fmt(_exp), valueColor: Tok.red2),
                PlRow(label: 'Net Farm Profit', value: _fmt(_net), valueColor: _net >= 0 ? Tok.green2 : Tok.red2, total: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
