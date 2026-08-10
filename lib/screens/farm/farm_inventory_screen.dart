import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/design_tokens.dart';
import '../../widgets/bm_card.dart';
import '../../widgets/form_field_widgets.dart';
import '../../widgets/shared_widgets.dart';
import '../../widgets/kpi_card.dart';
import '../../db/database_helper.dart';

class FarmInventoryScreen extends StatefulWidget {
  const FarmInventoryScreen({Key? key}) : super(key: key);
  @override
  State<FarmInventoryScreen> createState() => _FarmInventoryScreenState();
}

class _FarmInventoryScreenState extends State<FarmInventoryScreen> {
  final _db = DatabaseHelper.instance;
  bool _loading = true;
  int _goats = 0;
  double _val = 0;
  List<Map<String, dynamic>> _batches = [];
  
  int? _batchId;
  final _soldCtrl = TextEditingController();
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final g = await _db.getGoatsInStock();
    final v = await _db.getStockValue();
    final b = await _db.getCurrentBatches();

    if (mounted) {
      setState(() {
        _goats = g;
        _val = v;
        _batches = b;
        if (_batches.isNotEmpty && _batchId == null) _batchId = _batches.first['id'];
        _loading = false;
      });
    }
  }

  Future<void> _saveOut() async {
    if (_batchId == null || _soldCtrl.text.isEmpty) return;
    await _db.insertStockOut({
      'date': DateFormat('yyyy-MM-dd').format(_date),
      'purchase_id': _batchId,
      'goats_sold': int.tryParse(_soldCtrl.text) ?? 0,
      'amount': 0, // Used for manual adjustments without sale
    });
    _soldCtrl.clear();
    _load();
  }

  String _fmt(double v) => '₹${NumberFormat('#,##,###', 'en_IN').format(v.round())}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory / Stock Out', style: TextStyle(fontSize: 15))),
      body: _loading ? const Center(child: CircularProgressIndicator()) : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(child: KpiCard(title: 'Live Goats', value: '$_goats', accent: KpiAccent.green)),
              const SizedBox(width: 12),
              Expanded(child: KpiCard(title: 'Est. Stock Value', value: _fmt(_val), accent: KpiAccent.gold)),
            ],
          ),
          const SizedBox(height: 20),
          BmCard(
            child: Column(
              children: [
                const SectionLabel('Manual Stock Out (Death/Adjustment)'),
                BmDateSelect(label: 'Date', selectedDateStr: DateFormat('yyyy-MM-dd').format(_date), onTap: () {}),
                BmDropdown<int>(
                  label: 'Batch / Supplier',
                  value: _batchId,
                  items: _batches.map((e) => DropdownMenuItem(value: e['id'] as int, child: Text('Batch #${e['id']} — ${e['supplier_name']} (${e['remaining']} left)'))).toList(),
                  onChanged: (v) => setState(() => _batchId = v),
                ),
                BmTextField(label: 'Goats Removed', hint: '0', controller: _soldCtrl, keyboardType: TextInputType.number),
                SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _saveOut, child: const Text('ADJUST STOCK'))),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const SectionLabel('Current Batches'),
          ..._batches.map((b) => BmCard(
            margin: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Batch #${b['id']} — ${b['supplier_name']}', style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('${b['date']} · Cost: ${_fmt((b['cost'] as num).toDouble())}', style: const TextStyle(fontSize: 11, color: Tok.text3)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${b['remaining']} left', style: const TextStyle(fontWeight: FontWeight.w700, color: Tok.green2, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text('of ${b['goats']}', style: const TextStyle(fontSize: 11, color: Tok.text3)),
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
