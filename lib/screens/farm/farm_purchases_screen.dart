import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/design_tokens.dart';
import '../../widgets/bm_card.dart';
import '../../widgets/calc_strip.dart';
import '../../widgets/form_field_widgets.dart';
import '../../widgets/shared_widgets.dart';
import '../../widgets/data_table_widget.dart';
import '../../db/database_helper.dart';

class FarmPurchasesScreen extends StatefulWidget {
  const FarmPurchasesScreen({Key? key}) : super(key: key);
  @override
  State<FarmPurchasesScreen> createState() => _FarmPurchasesScreenState();
}

class _FarmPurchasesScreenState extends State<FarmPurchasesScreen> {
  final _db = DatabaseHelper.instance;
  int _tab = 0; // 0=Add Purchase, 1=Pay Supplier, 2=History
  bool _loading = true;

  // Data
  List<Map<String, dynamic>> _suppliers = [];
  List<Map<String, dynamic>> _balances = [];
  List<Map<String, dynamic>> _purchases = [];

  // Purchase Form
  int? _supplierId;
  final _goatsCtrl = TextEditingController();
  final _costCtrl = TextEditingController();
  final _paidCtrl = TextEditingController();
  final _remarksCtrl = TextEditingController();
  DateTime _date = DateTime.now();

  // Payment Form
  int? _paySupplierId;
  final _payAmtCtrl = TextEditingController();
  String _payMode = 'Bank/UPI';

  @override
  void initState() {
    super.initState();
    _load();
    _costCtrl.addListener(() => setState(() {}));
    _paidCtrl.addListener(() => setState(() {}));
  }

  Future<void> _load() async {
    final now = DateTime.now();
    final monthStart = DateFormat('yyyy-MM').format(now) + '-01';
    
    final sup = await _db.getSuppliers();
    final bal = await _db.getSupplierBalances();
    final pur = await _db.getFarmPurchases(monthStart: monthStart);

    if (mounted) {
      setState(() {
        _suppliers = sup;
        _balances = bal;
        _purchases = pur;
        if (_suppliers.isNotEmpty && _supplierId == null) _supplierId = _suppliers.first['id'];
        if (_balances.isNotEmpty && _paySupplierId == null) _paySupplierId = _balances.first['id'];
        _loading = false;
      });
    }
  }

  Future<void> _addSupplier() async {
    final c = TextEditingController();
    final res = await showDialog<String>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Add Supplier', style: TextStyle(fontSize: 14)),
      content: TextField(controller: c, decoration: const InputDecoration(hintText: 'Name')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(ctx, c.text), child: const Text('Add')),
      ],
    ));
    if (res != null && res.isNotEmpty) {
      await _db.insertSupplier(res);
      await _load();
    }
  }

  Future<void> _savePurchase() async {
    if (_supplierId == null || _costCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Supplier and Cost required')));
      return;
    }
    await _db.insertPurchase({
      'date': DateFormat('yyyy-MM-dd').format(_date),
      'supplier_id': _supplierId,
      'goats': int.tryParse(_goatsCtrl.text) ?? 0,
      'cost': double.tryParse(_costCtrl.text) ?? 0,
      'paid': double.tryParse(_paidCtrl.text) ?? 0,
      'remarks': _remarksCtrl.text,
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Purchase saved')));
    _goatsCtrl.clear(); _costCtrl.clear(); _paidCtrl.clear(); _remarksCtrl.clear();
    await _load();
    setState(() => _tab = 2);
  }

  Future<void> _savePayment() async {
    if (_paySupplierId == null || _payAmtCtrl.text.isEmpty) return;
    await _db.insertSupplierPayment({
      'date': DateFormat('yyyy-MM-dd').format(_date),
      'supplier_id': _paySupplierId,
      'amount': double.tryParse(_payAmtCtrl.text) ?? 0,
      'mode': _payMode,
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment saved')));
    _payAmtCtrl.clear();
    await _load();
  }

  Future<void> _del(int id) async {
    final c = await ConfirmDialog.show(context, title: 'Delete Purchase?', message: 'Will remove this batch.');
    if (c == true) { await _db.softDelete('farm_purchases', id, 'Purchase batch'); _load(); }
  }

  String _fmt(double v) => '₹${NumberFormat('#,##,###', 'en_IN').format(v.round())}';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('Purchases & Suppliers', style: TextStyle(fontSize: 15))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: BmTabBar(
              tabs: const ['Add Purchase', 'Pay Supplier', 'History'],
              selectedIndex: _tab,
              onTap: (i) => setState(() => _tab = i),
            ),
          ),
          Expanded(child: _loading ? const Center(child: CircularProgressIndicator()) : _buildContent(isDark)),
        ],
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    if (_tab == 0) return _buildAddForm();
    if (_tab == 1) return _buildPayForm(isDark);
    return _buildHistory(isDark);
  }

  Widget _buildAddForm() {
    final c = double.tryParse(_costCtrl.text) ?? 0;
    final p = double.tryParse(_paidCtrl.text) ?? 0;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        BmCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('Batch Details'),
              BmDateSelect(label: 'Date', selectedDateStr: DateFormat('yyyy-MM-dd').format(_date), onTap: () async {
                final d = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2020), lastDate: DateTime(2030));
                if (d != null) setState(() => _date = d);
              }),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: BmDropdown<int>(
                      label: 'Supplier',
                      value: _supplierId,
                      items: _suppliers.map((e) => DropdownMenuItem(value: e['id'] as int, child: Text(e['name']))).toList(),
                      onChanged: (v) => setState(() => _supplierId = v),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: IconButton(icon: const Icon(Icons.add_circle, color: Tok.gold), onPressed: _addSupplier),
                  ),
                ],
              ),
              BmTextField(label: 'No. of Goats', hint: '0', controller: _goatsCtrl, keyboardType: TextInputType.number),
              Row(
                children: [
                  Expanded(child: BmTextField(label: 'Total Cost (₹)', hint: '0', controller: _costCtrl, keyboardType: TextInputType.number)),
                  const SizedBox(width: 12),
                  Expanded(child: BmTextField(label: 'Paid Amount (₹)', hint: '0', controller: _paidCtrl, keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 12),
              CalcStrip(label: 'Remaining Balance', value: _fmt(c - p), negative: (c - p) > 0),
              const SizedBox(height: 16),
              BmTextField(label: 'Remarks', hint: 'Vehicle, expenses...', controller: _remarksCtrl),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _savePurchase, child: const Text('SAVE BATCH'))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPayForm(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        BmCard(
          child: Column(
            children: [
              const SectionLabel('Pay Supplier'),
              BmDateSelect(label: 'Date', selectedDateStr: DateFormat('yyyy-MM-dd').format(_date), onTap: () {}),
              BmDropdown<int>(
                label: 'Supplier',
                value: _paySupplierId,
                items: _balances.map((e) => DropdownMenuItem(value: e['id'] as int, child: Text('${e['name']} (${_fmt((e['balance'] as num).toDouble())})'))).toList(),
                onChanged: (v) => setState(() => _paySupplierId = v),
              ),
              Row(
                children: [
                  Expanded(child: BmTextField(label: 'Amount', hint: '0', controller: _payAmtCtrl, keyboardType: TextInputType.number)),
                  const SizedBox(width: 12),
                  Expanded(child: BmDropdown<String>(
                    label: 'Mode', value: _payMode, items: ['Bank/UPI', 'Cash'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setState(() => _payMode = v!),
                  )),
                ],
              ),
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _savePayment, child: const Text('RECORD PAYMENT'))),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const SectionLabel('Balances'),
        ..._balances.map((b) => BmCard(
          margin: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(b['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(_fmt((b['balance'] as num).toDouble()), style: const TextStyle(color: Tok.red2, fontWeight: FontWeight.bold)),
            ],
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildHistory(bool isDark) {
    if (_purchases.isEmpty) return const Center(child: Text('No purchases'));
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        BmDataTable(
          columns: const ['DATE', 'SUPPLIER', 'GOATS', 'COST', 'PAID', ''],
          rows: _purchases.map((p) => [
            Text(p['date']),
            Text(p['supplier_name'] ?? '-'),
            Text('${p['goats']}'),
            Text(_fmt((p['cost'] as num).toDouble())),
            Text(_fmt((p['paid'] as num).toDouble()), style: const TextStyle(color: Tok.green2)),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Tok.red, size: 18),
              padding: EdgeInsets.zero, constraints: const BoxConstraints(),
              onPressed: () => _del(p['id']),
            )
          ]).toList(),
        ),
      ],
    );
  }
}
