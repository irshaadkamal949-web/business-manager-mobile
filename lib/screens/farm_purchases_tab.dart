import 'package:flutter/material.dart';
import '../widgets/glass_card.dart';
import '../theme/app_theme.dart';
import '../db/database_helper.dart';

class FarmPurchasesTab extends StatefulWidget {
  const FarmPurchasesTab({Key? key}) : super(key: key);

  @override
  _FarmPurchasesTabState createState() => _FarmPurchasesTabState();
}

class _FarmPurchasesTabState extends State<FarmPurchasesTab> {
  List<Map<String, dynamic>> _purchases = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPurchases();
  }

  Future<void> _loadPurchases() async {
    final purchases = await DatabaseHelper.instance.getFarmPurchases();
    setState(() {
      _purchases = purchases;
      _isLoading = false;
    });
  }

  void _showAddPurchaseModal() {
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
                Text('Add Purchase (Create Batch)', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.goldAccent, fontFamily: 'serif')),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(labelText: 'Supplier', border: OutlineInputBorder()),
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
                    decoration: InputDecoration(labelText: 'Cost (Rs)', border: OutlineInputBorder()),
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
                  await DatabaseHelper.instance.insertPurchase({
                    'date': DateTime.now().toIso8601String(),
                    'supplier_id': 1, // Mock supplier ID
                    'goats': 25,
                    'cost': 120000,
                  });
                  Navigator.pop(context);
                  _loadPurchases();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Purchase Saved')));
                },
                icon: const Icon(Icons.check),
                label: const Text('Save Purchase', style: TextStyle(fontWeight: FontWeight.bold)),
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
        title: Text('Farm Purchases', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontFamily: 'serif')),
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
                onPressed: _showAddPurchaseModal,
                icon: const Icon(Icons.add),
                label: const Text('Add Purchase', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _purchases.isEmpty
                    ? const Center(child: Text('No purchases found.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _purchases.length,
                        itemBuilder: (context, index) {
                          final purchase = _purchases[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: GlassCard(
                              child: ListTile(
                                title: Text('Supplier ID: ${purchase['supplier_id']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('Goats: ${purchase['goats']} • Date: ${purchase['date']?.toString().split('T')[0]}'),
                                trailing: Text('Rs ${purchase['cost']}', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16)),
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
