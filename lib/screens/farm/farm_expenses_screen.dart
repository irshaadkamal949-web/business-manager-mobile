import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/design_tokens.dart';
import '../../widgets/bm_card.dart';
import '../../widgets/form_field_widgets.dart';
import '../../widgets/shared_widgets.dart';
import '../../db/database_helper.dart';

class FarmExpensesScreen extends StatefulWidget {
  const FarmExpensesScreen({Key? key}) : super(key: key);
  @override
  State<FarmExpensesScreen> createState() => _FarmExpensesScreenState();
}

class _FarmExpensesScreenState extends State<FarmExpensesScreen> {
  final _db = DatabaseHelper.instance;
  bool _loading = true;
  List<Map<String, dynamic>> _cats = [];
  List<Map<String, dynamic>> _exp = [];
  double _total = 0;

  int? _catId;
  final _amtCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _remarksCtrl = TextEditingController();
  String _mode = 'Cash';
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final now = DateTime.now();
    final monthStart = DateFormat('yyyy-MM').format(now) + '-01';
    
    final cats = await _db.getExpenseCategories();
    final exp = await _db.getFarmExpenses(monthStart: monthStart);
    final total = await _db.getFarmExpensesTotal(monthStart: monthStart);

    if (mounted) {
      setState(() {
        _cats = cats;
        _exp = exp;
        _total = total;
        if (_cats.isNotEmpty && _catId == null) _catId = _cats.first['id'];
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    if (_catId == null || _amtCtrl.text.isEmpty) return;
    await _db.insertFarmExpense({
      'date': DateFormat('yyyy-MM-dd').format(_date),
      'category_id': _catId,
      'description': _descCtrl.text,
      'amount': double.tryParse(_amtCtrl.text) ?? 0,
      'mode': _mode,
      'remarks': _remarksCtrl.text,
    });
    _amtCtrl.clear(); _descCtrl.clear(); _remarksCtrl.clear();
    _load();
  }

  Future<void> _del(int id) async {
    final c = await ConfirmDialog.show(context, title: 'Delete Expense?', message: 'Remove this expense.');
    if (c == true) { await _db.softDelete('farm_expenses', id, 'Farm Expense'); _load(); }
  }

  String _fmt(double v) => '₹${NumberFormat('#,##,###', 'en_IN').format(v.round())}';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('Farm Expenses', style: TextStyle(fontSize: 15))),
      body: _loading ? const Center(child: CircularProgressIndicator()) : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          BmCard(
            child: Column(
              children: [
                const SectionLabel('Record Expense'),
                BmDateSelect(label: 'Date', selectedDateStr: DateFormat('yyyy-MM-dd').format(_date), onTap: () async {
                  final d = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2020), lastDate: DateTime(2030));
                  if (d != null) setState(() => _date = d);
                }),
                BmDropdown<int>(
                  label: 'Category',
                  value: _catId,
                  items: _cats.map((e) => DropdownMenuItem(value: e['id'] as int, child: Text(e['name']))).toList(),
                  onChanged: (v) => setState(() => _catId = v),
                ),
                BmTextField(label: 'Description', hint: 'What was it for?', controller: _descCtrl),
                Row(
                  children: [
                    Expanded(child: BmTextField(label: 'Amount', hint: '0', controller: _amtCtrl, keyboardType: TextInputType.number)),
                    const SizedBox(width: 12),
                    Expanded(child: BmDropdown<String>(
                      label: 'Mode', value: _mode, items: ['Cash', 'Bank'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) => setState(() => _mode = v!),
                    )),
                  ],
                ),
                SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _save, child: const Text('SAVE EXPENSE'))),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Monthly Expenses', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Tok.text : Tok.textLight)),
              Text(_fmt(_total), style: const TextStyle(color: Tok.red2, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          ..._exp.map((e) => BmCard(
            margin: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(e['category_name'] ?? 'Exp', style: const TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(width: 8),
                          BadgeChip(label: e['mode'] ?? 'CASH', color: Tok.text3),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('${e['date']} · ${e['description']}', style: TextStyle(fontSize: 11, color: isDark ? Tok.text3 : Tok.text3Light)),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Text(_fmt((e['amount'] as num).toDouble()), style: const TextStyle(color: Tok.red2, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Tok.text3, size: 18),
                      onPressed: () => _del(e['id']),
                    ),
                  ],
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }
}
