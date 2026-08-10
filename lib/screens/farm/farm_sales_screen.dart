import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/design_tokens.dart';
import '../../widgets/bm_card.dart';
import '../../widgets/calc_strip.dart';
import '../../widgets/form_field_widgets.dart';
import '../../widgets/shared_widgets.dart';
import '../../widgets/data_table_widget.dart';
import '../../db/database_helper.dart';

class FarmSalesScreen extends StatefulWidget {
  const FarmSalesScreen({Key? key}) : super(key: key);
  @override
  State<FarmSalesScreen> createState() => _FarmSalesScreenState();
}

class _FarmSalesScreenState extends State<FarmSalesScreen> {
  final _db = DatabaseHelper.instance;
  int _tab = 0; // 0=Add Sale, 1=Log, 2=Returns
  bool _loading = true;

  // Add Sale Form
  String _payType = 'Cash';
  final _buyerCtrl = TextEditingController();
  final _goatsCtrl = TextEditingController();
  final _amtCtrl = TextEditingController();
  final _discCtrl = TextEditingController();
  final _advCtrl = TextEditingController();
  final _advByCtrl = TextEditingController();
  final _laterCtrl = TextEditingController();
  final _billCtrl = TextEditingController();
  final _tokenCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _remarksCtrl = TextEditingController();
  DateTime _date = DateTime.now();

  // Log
  List<Map<String, dynamic>> _sales = [];
  double _totalNet = 0;

  @override
  void initState() {
    super.initState();
    _loadSales();
    _addListeners();
  }

  void _addListeners() {
    _amtCtrl.addListener(() => setState(() {}));
    _discCtrl.addListener(() => setState(() {}));
    _advCtrl.addListener(() => setState(() {}));
    _laterCtrl.addListener(() => setState(() {}));
  }

  Future<void> _loadSales() async {
    final now = DateTime.now();
    final monthStart = DateFormat('yyyy-MM').format(now) + '-01';
    final sales = await _db.getFarmSales(monthStart: monthStart);
    final stats = await _db.getFarmSalesStats(monthStart: monthStart);
    
    if (mounted) {
      setState(() {
        _sales = sales;
        _totalNet = stats['totalNet'] ?? 0;
        _loading = false;
      });
    }
  }

  double _calcNet() {
    final a = double.tryParse(_amtCtrl.text) ?? 0;
    final d = double.tryParse(_discCtrl.text) ?? 0;
    return a - d;
  }
  
  double _calcBal() {
    final net = _calcNet();
    final adv = double.tryParse(_advCtrl.text) ?? 0;
    final later = double.tryParse(_laterCtrl.text) ?? 0;
    return net - adv - later;
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2020), lastDate: DateTime(2030));
    if (d != null) setState(() => _date = d);
  }

  Future<void> _save() async {
    if (_buyerCtrl.text.isEmpty || _amtCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Buyer and Amount required')));
      return;
    }
    await _db.insertSale({
      'date': DateFormat('yyyy-MM-dd').format(_date),
      'buyer': _buyerCtrl.text,
      'pay_type': _payType,
      'goats': int.tryParse(_goatsCtrl.text) ?? 0,
      'amount': double.tryParse(_amtCtrl.text) ?? 0,
      'discount': double.tryParse(_discCtrl.text) ?? 0,
      'advance': double.tryParse(_advCtrl.text) ?? 0,
      'adv_by': _advByCtrl.text,
      'received_later': double.tryParse(_laterCtrl.text) ?? 0,
      'bill_no': _billCtrl.text,
      'token': _tokenCtrl.text,
      'weight': _weightCtrl.text,
      'remarks': _remarksCtrl.text,
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sale saved')));
    // Reset
    _buyerCtrl.clear(); _goatsCtrl.clear(); _amtCtrl.clear(); _discCtrl.clear();
    _advCtrl.clear(); _advByCtrl.clear(); _laterCtrl.clear(); _billCtrl.clear();
    _tokenCtrl.clear(); _weightCtrl.clear(); _remarksCtrl.clear();
    _loadSales();
    setState(() => _tab = 1);
  }

  Future<void> _delete(int id) async {
    final conf = await ConfirmDialog.show(context, title: 'Delete Sale?', message: 'This will hide the sale from reports.');
    if (conf == true) {
      await _db.softDeleteSale(id);
      _loadSales();
    }
  }

  String _fmt(double v) => '₹${NumberFormat('#,##,###', 'en_IN').format(v.round())}';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales & Returns', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        backgroundColor: isDark ? Tok.bg : Tok.bgLight,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: isDark ? Tok.border : Tok.borderLight, height: 1),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: BmTabBar(
              tabs: const ['Add Sale', 'Sale Log', 'Returns'],
              selectedIndex: _tab,
              onTap: (i) => setState(() => _tab = i),
            ),
          ),
          Expanded(
            child: _loading ? const Center(child: CircularProgressIndicator(color: Tok.gold)) : _buildContent(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    if (_tab == 0) return _buildAddForm(isDark);
    if (_tab == 1) return _buildLog(isDark);
    return const Center(child: Text('Returns coming soon'));
  }

  Widget _buildAddForm(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        BmCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('Sale Details'),
              BmDateSelect(label: 'Date', selectedDateStr: DateFormat('yyyy-MM-dd').format(_date), onTap: _pickDate),
              BmTextField(label: 'Buyer Name', hint: 'Enter buyer name', controller: _buyerCtrl),
              BmDropdown<String>(
                label: 'Payment Type',
                value: _payType,
                items: ['Cash', 'Bank/UPI', 'Credit'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => _payType = v!),
              ),
              Row(
                children: [
                  Expanded(child: BmTextField(label: 'No. of Goats', hint: '0', controller: _goatsCtrl, keyboardType: TextInputType.number)),
                  const SizedBox(width: 12),
                  Expanded(child: BmTextField(label: 'Total Amount (₹)', hint: '0', controller: _amtCtrl, keyboardType: TextInputType.number)),
                ],
              ),
              BmTextField(label: 'Discount Given (₹)', hint: '0', controller: _discCtrl, keyboardType: TextInputType.number),
              
              const SizedBox(height: 12),
              CalcStrip(label: 'Net Bill Amount', value: _fmt(_calcNet())),
              
              if (_payType == 'Credit') ...[
                const SizedBox(height: 16),
                const SectionLabel('Credit Details'),
                Row(
                  children: [
                    Expanded(child: BmTextField(label: 'Advance (₹)', hint: '0', controller: _advCtrl, keyboardType: TextInputType.number)),
                    const SizedBox(width: 12),
                    Expanded(child: BmTextField(label: 'Advance By', hint: 'Mode', controller: _advByCtrl)),
                  ],
                ),
                BmTextField(label: 'Received Later (₹)', hint: '0', controller: _laterCtrl, keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                CalcStrip(label: 'Balance Remaining', value: _fmt(_calcBal()), negative: _calcBal() > 0),
              ],
              
              const SizedBox(height: 16),
              const SectionLabel('Optional Info'),
              Row(
                children: [
                  Expanded(child: BmTextField(label: 'Bill No.', hint: '#', controller: _billCtrl)),
                  const SizedBox(width: 12),
                  Expanded(child: BmTextField(label: 'Token', hint: '#', controller: _tokenCtrl)),
                ],
              ),
              BmTextField(label: 'Weight (kg)', hint: 'Total or Avg', controller: _weightCtrl),
              BmTextField(label: 'Remarks', hint: 'Notes...', controller: _remarksCtrl),
              
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(onPressed: _save, child: const Text('SAVE SALE')),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLog(bool isDark) {
    final rows = _sales.map((s) {
      final net = (s['amount'] as num) - (s['discount'] as num);
      final t = s['pay_type'] as String;
      final badge = t == 'Cash' ? BadgeChip.cash() : (t == 'Credit' ? BadgeChip.credit() : BadgeChip.bank());
      return [
        Text(s['date']),
        Text(s['buyer']),
        badge,
        Text('${s['goats']}'),
        Text(_fmt(net.toDouble()), style: const TextStyle(fontWeight: FontWeight.w600)),
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Tok.red, size: 18),
          padding: EdgeInsets.zero, constraints: const BoxConstraints(),
          onPressed: () => _delete(s['id']),
        )
      ];
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Monthly Total: ${_fmt(_totalNet)}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? Tok.text : Tok.textLight)),
            Text('${_sales.length} records', style: TextStyle(fontSize: 11, color: isDark ? Tok.text3 : Tok.text3Light)),
          ],
        ),
        const SizedBox(height: 12),
        if (rows.isEmpty)
          const Padding(padding: EdgeInsets.all(20), child: Center(child: Text('No sales this month')))
        else
          BmDataTable(
            columns: const ['DATE', 'BUYER', 'TYPE', 'GOATS', 'NET', ''],
            rows: rows,
          ),
      ],
    );
  }
}
