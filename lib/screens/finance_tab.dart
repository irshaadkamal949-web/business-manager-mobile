import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/design_tokens.dart';
import '../widgets/bm_card.dart';
import '../widgets/shared_widgets.dart';
import '../db/database_helper.dart';

class FinanceTab extends StatefulWidget {
  const FinanceTab({Key? key}) : super(key: key);
  @override
  State<FinanceTab> createState() => _FinanceTabState();
}

class _FinanceTabState extends State<FinanceTab> {
  final _db = DatabaseHelper.instance;
  bool _loading = true;
  String _monthStart = DateFormat('yyyy-MM').format(DateTime.now()) + '-01';

  // Farm
  double _farmSales = 0, _farmPurchases = 0, _farmExp = 0, _farmNet = 0;
  
  // Shop
  double _shopPur = 0, _shopSales = 0, _shopExp = 0, _shopNet = 0;
  
  // Consolidated
  double _totalNet = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // Farm
    final fs = await _db.getFarmSalesStats(monthStart: _monthStart);
    final fp = await _db.getFarmPurchaseCostMonth(monthStart: _monthStart);
    final fe = await _db.getFarmExpensesTotal(monthStart: _monthStart);
    
    // Shop
    final ss = await _db.getShopDailyStats(monthStart: _monthStart);
    final se = await _db.getShopExpensesTotal(monthStart: _monthStart);

    if (mounted) {
      setState(() {
        _farmSales = fs['totalNet'] ?? 0;
        _farmPurchases = fp;
        _farmExp = fe;
        _farmNet = _farmSales - _farmPurchases - _farmExp;

        _shopPur = ss['totalPurchases'] ?? 0;
        _shopSales = (ss['netProfit'] ?? 0) + _shopPur; // reverse engineered
        _shopExp = se;
        _shopNet = (ss['netProfit'] ?? 0) - _shopExp;
        
        _totalNet = _farmNet + _shopNet;
        _loading = false;
      });
    }
  }

  String _fmt(double v) => '₹${NumberFormat('#,##,###', 'en_IN').format(v.round())}';

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Profit & Loss Statement', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Tok.text : Tok.textLight)),
            Text(DateFormat('MMMM yyyy').format(DateTime.parse(_monthStart)), style: const TextStyle(fontSize: 13, color: Tok.gold, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 20),

        // Net P&L Card
        Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: isDark ? Tok.card : Tok.cardLight,
            border: Border.all(color: Tok.goldBorder),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Tok.gold.withOpacity(0.1), blurRadius: 10, spreadRadius: 1)],
          ),
          child: Column(
            children: [
              Text('CONSOLIDATED NET PROFIT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: isDark ? Tok.text3 : Tok.text3Light)),
              const SizedBox(height: 8),
              Text(_fmt(_totalNet), style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: _totalNet >= 0 ? Tok.green2 : Tok.red2, fontFamily: 'serif')),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Farm P&L
        BmCard(
          child: Column(
            children: [
              const SectionLabel('Goat Farm (Wholesale)'),
              PlRow(label: 'Farm Sales', value: _fmt(_farmSales)),
              PlRow(label: 'Less: Farm Purchases', value: _fmt(_farmPurchases), valueColor: Tok.red2),
              PlRow(label: 'Farm Gross Profit', value: _fmt(_farmSales - _farmPurchases), bold: true),
              PlRow(label: 'Less: Farm Expenses', value: _fmt(_farmExp), valueColor: Tok.red2),
              PlRow(label: 'Farm Net Profit', value: _fmt(_farmNet), valueColor: _farmNet >= 0 ? Tok.green2 : Tok.red2, total: true),
            ],
          ),
        ),

        // Shop P&L
        BmCard(
          child: Column(
            children: [
              const SectionLabel('Mutton Shop (Retail)'),
              PlRow(label: 'Shop Total Income', value: _fmt(_shopSales)),
              PlRow(label: 'Less: Goats Purchased', value: _fmt(_shopPur), valueColor: Tok.red2),
              PlRow(label: 'Shop Gross Profit', value: _fmt(_shopSales - _shopPur), bold: true),
              PlRow(label: 'Less: Shop Expenses', value: _fmt(_shopExp), valueColor: Tok.red2),
              PlRow(label: 'Shop Net Profit', value: _fmt(_shopNet), valueColor: _shopNet >= 0 ? Tok.green2 : Tok.red2, total: true),
            ],
          ),
        ),
        
        // Month selector (Dummy for UI logic for now)
        const SizedBox(height: 30),
        Center(child: TextButton.icon(
          icon: const Icon(Icons.calendar_month, color: Tok.text3),
          label: const Text('Change Month', style: TextStyle(color: Tok.text3)),
          onPressed: () {},
        )),
      ],
    );
  }
}
