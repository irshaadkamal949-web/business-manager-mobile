import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/design_tokens.dart';
import '../../widgets/bm_card.dart';
import '../../widgets/kpi_card.dart';
import '../../widgets/form_field_widgets.dart';
import '../../widgets/shared_widgets.dart';
import '../../db/database_helper.dart';

class ShopCreditScreen extends StatefulWidget {
  const ShopCreditScreen({Key? key}) : super(key: key);
  @override
  State<ShopCreditScreen> createState() => _ShopCreditScreenState();
}

class _ShopCreditScreenState extends State<ShopCreditScreen> {
  final _db = DatabaseHelper.instance;
  bool _loading = true;
  double _total = 0;
  List<Map<String, dynamic>> _custs = [];
  List<Map<String, dynamic>> _bals = [];

  int? _custId;
  final _givenCtrl = TextEditingController();
  final _colCtrl = TextEditingController();
  final _discCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _mode = 'Cash';
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final t = await _db.getTotalShopCredit();
    final c = await _db.getCustomers();
    final b = await _db.getCustomerBalances();
    if (mounted) {
      setState(() {
        _total = t;
        _custs = c;
        _bals = b;
        if (_custs.isNotEmpty && _custId == null) _custId = _custs.first['id'];
        _loading = false;
      });
    }
  }

  Future<void> _addCust() async {
    final c = TextEditingController();
    final res = await showDialog<String>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Add Customer', style: TextStyle(fontSize: 14)),
      content: TextField(controller: c, decoration: const InputDecoration(hintText: 'Name')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(ctx, c.text), child: const Text('Add')),
      ],
    ));
    if (res != null && res.isNotEmpty) {
      await _db.insertCustomer(res);
      await _load();
    }
  }

  Future<void> _save() async {
    if (_custId == null) return;
    final g = double.tryParse(_givenCtrl.text) ?? 0;
    final c = double.tryParse(_colCtrl.text) ?? 0;
    final d = double.tryParse(_discCtrl.text) ?? 0;
    if (g == 0 && c == 0 && d == 0) return;

    await _db.insertShopCredit({
      'date': DateFormat('yyyy-MM-dd').format(_date),
      'customer_id': _custId,
      'credit_given': g,
      'collected': c,
      'discount': d,
      'mode': c > 0 ? _mode : '',
      'notes': _notesCtrl.text,
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Credit Logged')));
    _givenCtrl.clear(); _colCtrl.clear(); _discCtrl.clear(); _notesCtrl.clear();
    _load();
  }

  String _fmt(double v) => '₹${NumberFormat('#,##,###', 'en_IN').format(v.round())}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Credit Recorder', style: TextStyle(fontSize: 15))),
      body: _loading ? const Center(child: CircularProgressIndicator()) : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(child: KpiCard(title: 'Total Outstanding', value: _fmt(_total), accent: KpiAccent.red)),
              const SizedBox(width: 12),
              Expanded(child: KpiCard(title: 'Active Accounts', value: '${_bals.length}', accent: KpiAccent.gold)),
            ],
          ),
          const SizedBox(height: 20),
          BmCard(
            child: Column(
              children: [
                const SectionLabel('Record Credit / Collection'),
                BmDateSelect(label: 'Date', selectedDateStr: DateFormat('yyyy-MM-dd').format(_date), onTap: () {}),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: BmDropdown<int>(
                        label: 'Customer',
                        value: _custId,
                        items: _custs.map((e) => DropdownMenuItem(value: e['id'] as int, child: Text(e['name']))).toList(),
                        onChanged: (v) => setState(() => _custId = v),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: IconButton(icon: const Icon(Icons.add_circle, color: Tok.gold), onPressed: _addCust),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: BmTextField(label: 'Meat Given (₹)', hint: '0', controller: _givenCtrl, keyboardType: TextInputType.number)),
                    const SizedBox(width: 12),
                    Expanded(child: BmTextField(label: 'Collected (₹)', hint: '0', controller: _colCtrl, keyboardType: TextInputType.number)),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: BmTextField(label: 'Discount (₹)', hint: '0', controller: _discCtrl, keyboardType: TextInputType.number)),
                    const SizedBox(width: 12),
                    Expanded(child: BmDropdown<String>(
                      label: 'Mode', value: _mode, items: ['Cash', 'Bank'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) => setState(() => _mode = v!),
                    )),
                  ],
                ),
                BmTextField(label: 'Notes', hint: 'Optional details', controller: _notesCtrl),
                SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _save, child: const Text('SAVE RECORD'))),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const SectionLabel('Customer Balances'),
          ..._bals.map((b) {
            final bal = (b['balance'] as num).toDouble();
            return BmCard(
              margin: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(b['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(_fmt(bal), style: TextStyle(color: bal > 0 ? Tok.red2 : Tok.green2, fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
