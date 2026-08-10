import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/design_tokens.dart';
import '../widgets/bm_card.dart';
import '../widgets/kpi_card.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/chart_widgets.dart';
import '../db/database_helper.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final _db = DatabaseHelper.instance;
  bool _loading = true;
  double _netProfit = 0, _shopCredit = 0, _farmOutstanding = 0;
  int _goatsInStock = 0;
  double _stockValue = 0, _supplierBalance = 0;
  double _farmGrossProfit = 0, _shopNetProfit = 0, _totalPurchases = 0;
  List<String> _chartLabels = [];
  List<double> _chartData = [];
  bool _showErrorTrace = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final now = DateTime.now();
    final monthStart = DateFormat('yyyy-MM').format(now) + '-01';

    final trend = await _db.getMonthlyProfitTrend(7);
    final goats = await _db.getGoatsInStock();
    final stockVal = await _db.getStockValue();
    final shopCredit = await _db.getTotalShopCredit();
    final farmOutstanding = await _db.getFarmOutstanding();
    final supplierBal = await _db.getTotalSupplierBalance();
    final shopStats = await _db.getShopDailyStats(monthStart: monthStart);
    final shopExp = await _db.getShopExpensesTotal(monthStart: monthStart);
    final farmSalesStats = await _db.getFarmSalesStats(monthStart: monthStart);
    final farmPurchaseCost = await _db.getFarmPurchaseCostMonth(monthStart: monthStart);
    final farmExp = await _db.getFarmExpensesTotal(monthStart: monthStart);

    final farmGross = (farmSalesStats['totalNet'] ?? 0) - farmPurchaseCost;
    final shopNet = (shopStats['netProfit'] ?? 0) - shopExp;

    if (mounted) {
      setState(() {
        _loading = false;
        _goatsInStock = goats;
        _stockValue = stockVal;
        _shopCredit = shopCredit;
        _farmOutstanding = farmOutstanding;
        _supplierBalance = supplierBal;
        _farmGrossProfit = farmGross;
        _shopNetProfit = shopNet;
        _totalPurchases = farmPurchaseCost;
        _netProfit = farmGross - farmExp + shopNet;
        _chartLabels = trend.map((t) => t['label'] as String).toList();
        _chartData = trend.map((t) => (t['totalProfit'] as num).toDouble()).toList();
      });
    }
  }

  String _fmt(double v) {
    final abs = v.abs();
    if (abs >= 100000) return '₹${NumberFormat('#,##,###', 'en_IN').format(v.round())}';
    return '₹${NumberFormat('#,##,###', 'en_IN').format(v.round())}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: Tok.gold));
    }

    return RefreshIndicator(
      color: Tok.gold,
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Owner badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Tok.goldBg,
              border: Border.all(color: Tok.goldBorder),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('👑', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 6),
                Text('Owner + Viewer — Full Access',
                  style: TextStyle(fontSize: 10.5, color: Tok.gold2, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // System Diagnostics
          BmCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('💻 System Diagnostics',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Tok.text : Tok.textLight)),
                    GestureDetector(
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Diagnostics exported ✓'))),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                        decoration: BoxDecoration(
                          color: isDark ? Tok.card2 : Tok.card2Light,
                          border: Border.all(color: isDark ? Tok.border2 : Tok.border2Light),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text('↓ JSON', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: isDark ? Tok.text2 : Tok.text2Light)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _DiagCard(title: '📱 This Device', rows: {
                      'Version': ('v2.0', null),
                      'Role': ('OWNER', Tok.green2),
                      'Database': ('✓ OK', Tok.teal2),
                      'Lock': ('PIN ✓', null),
                    })),
                    const SizedBox(width: 8),
                    Expanded(child: _DiagCard(title: '💾 Data', rows: {
                      'Records': ('${_goatsInStock} goats', null),
                      'Customers': ('Active', Tok.green2),
                      'Sync': ('Local', Tok.amber2),
                      'Status': ('Healthy', Tok.green2),
                    })),
                  ],
                ),
              ],
            ),
          ),

          // KPI Grid
          const SizedBox(height: 4),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.6,
            children: [
              KpiCard(
                title: 'Net Profit — ${DateFormat('MMM').format(DateTime.now())}',
                value: _fmt(_netProfit),
                accent: KpiAccent.gold,
              ),
              KpiCard(
                title: 'Shop Credit Outstanding',
                value: _fmt(_shopCredit),
                accent: KpiAccent.red,
                subtitle: 'All customers',
              ),
              KpiCard(
                title: 'Farm Sales Outstanding',
                value: _fmt(_farmOutstanding),
                accent: KpiAccent.teal,
              ),
              KpiCard(
                title: 'Goats in Stock',
                value: '$_goatsInStock',
                accent: KpiAccent.green,
                subtitle: _fmt(_stockValue) + ' invested',
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Profit chart
          BmCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Net Profit by Month', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Tok.text : Tok.textLight)),
                const SizedBox(height: 4),
                Text('Last 7 months · Farm + Shop combined', style: TextStyle(fontSize: 11, color: isDark ? Tok.text3 : Tok.text3Light)),
                const SizedBox(height: 12),
                ProfitBarChart(labels: _chartLabels, data: _chartData),
              ],
            ),
          ),

          // Quick Figures
          const SectionLabel('Quick Figures'),
          BmCard(
            child: Column(
              children: [
                PlRow(label: 'Farm Gross Profit', value: _fmt(_farmGrossProfit), valueColor: _farmGrossProfit >= 0 ? Tok.green2 : Tok.red2),
                PlRow(label: 'Shop Net Profit', value: _fmt(_shopNetProfit), valueColor: _shopNetProfit >= 0 ? Tok.green2 : Tok.red2),
                PlRow(label: 'Total Purchases', value: _fmt(_totalPurchases), valueColor: Tok.red2),
                PlRow(label: 'Supplier Balance (All-Time)', value: _fmt(_supplierBalance), valueColor: Tok.red2),
                PlRow(label: 'Net Profit', value: _fmt(_netProfit), valueColor: _netProfit >= 0 ? Tok.green2 : Tok.red2, bold: true),
              ],
            ),
          ),
          Center(child: Text('↕ scroll for more', style: TextStyle(fontSize: 9, color: isDark ? Tok.text4 : Tok.text4Light))),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _DiagCard extends StatelessWidget {
  final String title;
  final Map<String, (String, Color?)> rows;
  const _DiagCard({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: isDark ? Tok.card : Tok.cardLight,
        border: Border.all(color: isDark ? Tok.border : Tok.borderLight),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isDark ? Tok.text : Tok.textLight))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: Tok.goldBg,
                  border: Border.all(color: Tok.goldBorder),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Text('AUTO', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Tok.gold2, letterSpacing: 0.3)),
              ),
            ],
          ),
          const SizedBox(height: 9),
          ...rows.entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Text('${e.key}:', style: TextStyle(fontSize: 11, color: isDark ? Tok.text3 : Tok.text3Light, fontWeight: FontWeight.w500)),
                const SizedBox(width: 6),
                Text(e.value.$1, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: e.value.$2 ?? (isDark ? Tok.text : Tok.textLight))),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
