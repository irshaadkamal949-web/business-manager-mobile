import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/design_tokens.dart';
import '../../widgets/bm_card.dart';
import '../../widgets/calc_strip.dart';
import '../../widgets/form_field_widgets.dart';
import '../../widgets/shared_widgets.dart';
import '../../widgets/data_table_widget.dart';
import '../../db/database_helper.dart';

class ShopDailyLogScreen extends StatefulWidget {
  const ShopDailyLogScreen({Key? key}) : super(key: key);
  @override
  State<ShopDailyLogScreen> createState() => _ShopDailyLogScreenState();
}

class _ShopDailyLogScreenState extends State<ShopDailyLogScreen> {
  final _db = DatabaseHelper.instance;
  int _tab = 0; // 0=Day Entry, 1=Monthly Expenses, 2=Log
  bool _loading = true;

  // Day Entry
  final _goatsCtrl = TextEditingController();
  final _purCostCtrl = TextEditingController();
  final _openMeatCtrl = TextEditingController();
  final _salesCtrl = TextEditingController();
  final _closeMeatCtrl = TextEditingController();
  final _skinCtrl = TextEditingController();
  final _akeekCtrl = TextEditingController();
  final _extraCtrl = TextEditingController();
  final _salaryCtrl = TextEditingController();
  final _otherCtrl = TextEditingController();
  final _miscCtrl = TextEditingController();
  final _discCtrl = TextEditingController();
  DateTime _date = DateTime.now();

  // Expenses
  final _expAmtCtrl = TextEditingController();
  final _expDescCtrl = TextEditingController();
  String _expCat = 'Rent';
  DateTime _expDate = DateTime.now();

  // Log
  List<Map<String, dynamic>> _logs = [];
  List<Map<String, dynamic>> _expenses = [];
  double _monthProfit = 0;

  @override
  void initState() {
    super.initState();
    _load();
    for (var c in [_purCostCtrl, _salesCtrl, _skinCtrl, _akeekCtrl, _extraCtrl, _salaryCtrl, _otherCtrl, _miscCtrl, _discCtrl]) {
      c.addListener(() => setState(() {}));
    }
  }

  Future<void> _load() async {
    final now = DateTime.now();
    final monthStart = DateFormat('yyyy-MM').format(now) + '-01';
    final l = await _db.getShopDailyLogs(monthStart: monthStart);
    final e = await _db.getShopExpenses(monthStart: monthStart);
    final s = await _db.getShopDailyStats(monthStart: monthStart);
    final et = await _db.getShopExpensesTotal(monthStart: monthStart);
    
    if (mounted) {
      setState(() {
        _logs = l;
        _expenses = e;
        _monthProfit = (s['netProfit'] ?? 0) - et;
        _loading = false;
      });
    }
  }

  double _v(TextEditingController c) => double.tryParse(c.text) ?? 0;

  double _calcIncome() => _v(_salesCtrl) + _v(_skinCtrl) + _v(_akeekCtrl) + _v(_extraCtrl);
  double _calcExpense() => _v(_purCostCtrl) + _v(_salaryCtrl) + _v(_otherCtrl) + _v(_miscCtrl) + _v(_discCtrl);
  double _calcNet() => _calcIncome() - _calcExpense();

  Future<void> _saveDay() async {
    await _db.insertShopDaily({
      'date': DateFormat('yyyy-MM-dd').format(_date),
      'goats': int.tryParse(_goatsCtrl.text) ?? 0,
      'purchase_cost': _v(_purCostCtrl),
      'opening_meat': _v(_openMeatCtrl),
      'sales': _v(_salesCtrl),
      'closing_meat': _v(_closeMeatCtrl),
      'skin': _v(_skinCtrl),
      'akeek': _v(_akeekCtrl),
      'extra_mutton': _v(_extraCtrl),
      'salary': _v(_salaryCtrl),
      'other_expense': _v(_otherCtrl),
      'misc': _v(_miscCtrl),
      'cust_discount': _v(_discCtrl),
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Day Log Saved')));
    for (var c in [_goatsCtrl, _purCostCtrl, _openMeatCtrl, _salesCtrl, _closeMeatCtrl, _skinCtrl, _akeekCtrl, _extraCtrl, _salaryCtrl, _otherCtrl, _miscCtrl, _discCtrl]) {
      c.clear();
    }
    await _load();
    setState(() => _tab = 2);
  }

  Future<void> _saveExp() async {
    if (_expAmtCtrl.text.isEmpty) return;
    await _db.insertShopExpense({
      'date': DateFormat('yyyy-MM-dd').format(_expDate),
      'category': _expCat,
      'amount': _v(_expAmtCtrl),
      'remarks': _expDescCtrl.text,
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Expense Saved')));
    _expAmtCtrl.clear(); _expDescCtrl.clear();
    await _load();
  }

  Future<void> _delLog(int id) async {
    final c = await ConfirmDialog.show(context, title: 'Delete Log?', message: 'Removes day entry.');
    if (c == true) { await _db.softDelete('shop_daily', id, 'Shop Day Log'); _load(); }
  }

  Future<void> _delExp(int id) async {
    final c = await ConfirmDialog.show(context, title: 'Delete Expense?', message: 'Removes expense.');
    if (c == true) { await _db.softDelete('shop_expenses', id, 'Shop Expense'); _load(); }
  }

  String _fmt(double v) => '₹${NumberFormat('#,##,###', 'en_IN').format(v.round())}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shop Daily Log', style: TextStyle(fontSize: 15))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: BmTabBar(tabs: const ['Day Entry', 'Monthly Expenses', 'Log'], selectedIndex: _tab, onTap: (i) => setState(() => _tab = i)),
          ),
          Expanded(child: _loading ? const Center(child: CircularProgressIndicator()) : _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_tab == 0) return _buildDayForm();
    if (_tab == 1) return _buildExpForm();
    return _buildLog();
  }

  Widget _buildDayForm() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        BmCard(
          child: Column(
            children: [
              BmDateSelect(label: 'Date', selectedDateStr: DateFormat('yyyy-MM-dd').format(_date), onTap: () async {
                final d = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2020), lastDate: DateTime(2030));
                if (d != null) setState(() => _date = d);
              }),
              const SectionLabel('Morning Details'),
              Row(
                children: [
                  Expanded(child: BmTextField(label: 'Goats Cut', hint: '0', controller: _goatsCtrl, keyboardType: TextInputType.number)),
                  const SizedBox(width: 12),
                  Expanded(child: BmTextField(label: 'Pur. Cost (₹)', hint: '0', controller: _purCostCtrl, keyboardType: TextInputType.number)),
                ],
              ),
              BmTextField(label: 'Opening Meat (kg)', hint: '0', controller: _openMeatCtrl, keyboardType: TextInputType.number),
              
              const SectionLabel('Income / Sales'),
              Row(
                children: [
                  Expanded(child: BmTextField(label: 'Counter Sales (₹)', hint: '0', controller: _salesCtrl, keyboardType: TextInputType.number)),
                  const SizedBox(width: 12),
                  Expanded(child: BmTextField(label: 'Closing Meat (kg)', hint: '0', controller: _closeMeatCtrl, keyboardType: TextInputType.number)),
                ],
              ),
              Row(
                children: [
                  Expanded(child: BmTextField(label: 'Skin / Bone (₹)', hint: '0', controller: _skinCtrl, keyboardType: TextInputType.number)),
                  const SizedBox(width: 12),
                  Expanded(child: BmTextField(label: 'Akeek (₹)', hint: '0', controller: _akeekCtrl, keyboardType: TextInputType.number)),
                ],
              ),
              BmTextField(label: 'Extra Mutton Sold (₹)', hint: '0', controller: _extraCtrl, keyboardType: TextInputType.number),
              
              const SectionLabel('Day Expenses'),
              Row(
                children: [
                  Expanded(child: BmTextField(label: 'Salary (₹)', hint: '0', controller: _salaryCtrl, keyboardType: TextInputType.number)),
                  const SizedBox(width: 12),
                  Expanded(child: BmTextField(label: 'Other / Ice (₹)', hint: '0', controller: _otherCtrl, keyboardType: TextInputType.number)),
                ],
              ),
              Row(
                children: [
                  Expanded(child: BmTextField(label: 'Misc / Tips (₹)', hint: '0', controller: _miscCtrl, keyboardType: TextInputType.number)),
                  const SizedBox(width: 12),
                  Expanded(child: BmTextField(label: 'Cust. Discount (₹)', hint: '0', controller: _discCtrl, keyboardType: TextInputType.number)),
                ],
              ),
              
              const SizedBox(height: 16),
              CalcStrip(label: 'Net Day Profit', value: _fmt(_calcNet()), negative: _calcNet() < 0),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _saveDay, child: const Text('SAVE DAY LOG'))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpForm() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        BmCard(
          child: Column(
            children: [
              const SectionLabel('Monthly Expenses'),
              BmDateSelect(label: 'Date', selectedDateStr: DateFormat('yyyy-MM-dd').format(_expDate), onTap: () {}),
              BmDropdown<String>(
                label: 'Category', value: _expCat, items: ['Rent', 'Electricity', 'Maintenance', 'Police', 'Other'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => _expCat = v!),
              ),
              BmTextField(label: 'Amount (₹)', hint: '0', controller: _expAmtCtrl, keyboardType: TextInputType.number),
              BmTextField(label: 'Description', hint: 'Notes...', controller: _expDescCtrl),
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _saveExp, child: const Text('RECORD EXPENSE'))),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ..._expenses.map((e) => BmCard(
          margin: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e['category'], style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text('${e['date']} · ${e['remarks']}', style: const TextStyle(fontSize: 11, color: Tok.text3)),
                ],
              ),
              Row(
                children: [
                  Text(_fmt((e['amount'] as num).toDouble()), style: const TextStyle(color: Tok.red2, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.delete, color: Tok.text3, size: 18), onPressed: () => _delExp(e['id'])),
                ],
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildLog() {
    final rows = _logs.map((l) {
      final inc = (l['sales'] as num) + (l['skin'] as num) + (l['akeek'] as num) + (l['extra_mutton'] as num);
      final exp = (l['purchase_cost'] as num) + (l['salary'] as num) + (l['other_expense'] as num) + (l['misc'] as num) + (l['cust_discount'] as num);
      final net = inc - exp;
      return [
        Text(l['date']),
        Text('${l['goats']}'),
        Text(_fmt(inc.toDouble())),
        Text(_fmt(exp.toDouble()), style: const TextStyle(color: Tok.red2)),
        Text(_fmt(net.toDouble()), style: TextStyle(fontWeight: FontWeight.w600, color: net >= 0 ? Tok.green2 : Tok.red2)),
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Tok.red, size: 18),
          padding: EdgeInsets.zero, constraints: const BoxConstraints(),
          onPressed: () => _delLog(l['id']),
        )
      ];
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Est. Month Profit: ${_fmt(_monthProfit)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            Text('${_logs.length} days', style: const TextStyle(fontSize: 11, color: Tok.text3)),
          ],
        ),
        const SizedBox(height: 12),
        if (rows.isEmpty) const Center(child: Text('No daily logs'))
        else BmDataTable(columns: const ['DATE', 'GOATS', 'INCOME', 'EXPENSE', 'PROFIT', ''], rows: rows),
      ],
    );
  }
}
