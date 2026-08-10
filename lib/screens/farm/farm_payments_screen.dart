import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/design_tokens.dart';
import '../../widgets/bm_card.dart';
import '../../widgets/form_field_widgets.dart';
import '../../widgets/shared_widgets.dart';
import '../../db/database_helper.dart';

class FarmPaymentsScreen extends StatefulWidget {
  const FarmPaymentsScreen({Key? key}) : super(key: key);
  @override
  State<FarmPaymentsScreen> createState() => _FarmPaymentsScreenState();
}

class _FarmPaymentsScreenState extends State<FarmPaymentsScreen> {
  final _db = DatabaseHelper.instance;
  bool _loading = true;
  double _outstanding = 0;
  List<Map<String, dynamic>> _pendingBills = [];

  // Form
  final _amtCtrl = TextEditingController();
  final _billCtrl = TextEditingController();
  final _remarksCtrl = TextEditingController();
  String _partner = 'KABEER';
  String _mode = 'Cash';
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final out = await _db.getFarmOutstanding();
    final dbInst = await _db.database;
    final bills = await dbInst.rawQuery('''
      SELECT id, date, buyer, amount, discount, advance, received_later,
        (amount - discount - advance - received_later) as bal
      FROM farm_sales
      WHERE deleted = 0 AND pay_type = 'Credit' AND (amount - discount - advance - received_later) > 0
      ORDER BY date ASC
    ''');

    if (mounted) {
      setState(() {
        _outstanding = out;
        _pendingBills = bills;
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    if (_amtCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Amount required')));
      return;
    }
    await _db.insertFarmPayment({
      'date': DateFormat('yyyy-MM-dd').format(_date),
      'amount': double.tryParse(_amtCtrl.text) ?? 0,
      'bill_no': _billCtrl.text,
      'partner': _partner,
      'mode': _mode,
      'remarks': _remarksCtrl.text,
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment saved')));
    _amtCtrl.clear(); _billCtrl.clear(); _remarksCtrl.clear();
    _load();
  }

  String _fmt(double v) => '₹${NumberFormat('#,##,###', 'en_IN').format(v.round())}';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farm Payment Receiving', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        backgroundColor: isDark ? Tok.bg : Tok.bgLight,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: isDark ? Tok.border : Tok.borderLight, height: 1),
        ),
      ),
      body: _loading ? const Center(child: CircularProgressIndicator(color: Tok.gold)) : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Total
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: isDark ? Tok.card : Tok.cardLight,
              border: Border.all(color: Tok.red.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(12),
              boxShadow: isDark ? Tok.shadowCard : Tok.shadowCardLight,
            ),
            child: Column(
              children: [
                Text('Total Farm Outstanding', style: TextStyle(fontSize: 11, color: isDark ? Tok.text3 : Tok.text3Light)),
                const SizedBox(height: 8),
                Text(_fmt(_outstanding), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Tok.red2, fontFamily: 'serif')),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Form
          BmCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionLabel('Receive Payment'),
                BmDateSelect(label: 'Date', selectedDateStr: DateFormat('yyyy-MM-dd').format(_date), onTap: () async {
                  final d = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2020), lastDate: DateTime(2030));
                  if (d != null) setState(() => _date = d);
                }),
                Row(
                  children: [
                    Expanded(child: BmDropdown<String>(
                      label: 'Received By',
                      value: _partner,
                      items: ['KABEER', 'HI-TECH'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) => setState(() => _partner = v!),
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: BmTextField(label: 'Ref Bill No.', hint: '#', controller: _billCtrl)),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: BmTextField(label: 'Amount (₹)', hint: '0', controller: _amtCtrl, keyboardType: TextInputType.number)),
                    const SizedBox(width: 12),
                    Expanded(child: BmDropdown<String>(
                      label: 'Mode',
                      value: _mode,
                      items: ['Cash', 'Bank'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) => setState(() => _mode = v!),
                    )),
                  ],
                ),
                BmTextField(label: 'Remarks', hint: 'Notes...', controller: _remarksCtrl),
                const SizedBox(height: 12),
                SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _save, child: const Text('SAVE PAYMENT'))),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          const SectionLabel('Pending Bills'),
          if (_pendingBills.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('No pending bills')))
          else
            ..._pendingBills.map((b) => BmCard(
              margin: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(b['buyer'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text('${b['date']} · Bill #${b['id']}', style: TextStyle(color: isDark ? Tok.text3 : Tok.text3Light, fontSize: 10)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(_fmt((b['bal'] as num).toDouble()), style: const TextStyle(fontWeight: FontWeight.w700, color: Tok.red2, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text('of ${_fmt((b['amount'] as num).toDouble())}', style: TextStyle(color: isDark ? Tok.text3 : Tok.text3Light, fontSize: 10)),
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
