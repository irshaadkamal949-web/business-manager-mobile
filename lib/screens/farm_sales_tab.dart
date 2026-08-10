import 'package:flutter/material.dart';
import '../widgets/glass_card.dart';
import '../theme/app_theme.dart';
import '../db/database_helper.dart';

class FarmSalesTab extends StatefulWidget {
  const FarmSalesTab({Key? key}) : super(key: key);

  @override
  _FarmSalesTabState createState() => _FarmSalesTabState();
}

class _FarmSalesTabState extends State<FarmSalesTab> {
  List<Map<String, dynamic>> _sales = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  Future<void> _loadSales() async {
    final sales = await DatabaseHelper.instance.getFarmSales();
    setState(() {
      _sales = sales;
      _isLoading = false;
    });
  }

  void _showAddSaleModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          top: 24, left: 24, right: 24,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.goldAccent.withOpacity(0.5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Add Sale', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.goldAccent, fontFamily: 'serif')),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(labelText: 'Buyer Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            Row(
              children: const [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(labelText: 'No. of Goats', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(labelText: 'Sale Amount (Rs)', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.goldAccent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  await DatabaseHelper.instance.insertSale({
                    'date': DateTime.now().toIso8601String(),
                    'buyer': 'Test Buyer',
                    'goats': 2,
                    'amount': 45000,
                  });
                  Navigator.pop(context);
                  _loadSales();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sale Saved')));
                },
                icon: const Icon(Icons.check),
                label: const Text('Save Sale', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Farm Sales & Returns', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontFamily: 'serif')),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.goldAccent, foregroundColor: Colors.black),
                onPressed: _showAddSaleModal,
                icon: const Icon(Icons.add),
                label: const Text('Add Sale', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _sales.isEmpty
                    ? const Center(child: Text('No sales found.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _sales.length,
                        itemBuilder: (context, index) {
                          final sale = _sales[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: GlassCard(
                              child: ListTile(
                                title: Text(sale['buyer'] ?? 'Unknown Buyer', style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('Goats: ${sale['goats']} • Date: ${sale['date']?.toString().split('T')[0]}'),
                                trailing: Text('Rs ${sale['amount']}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
