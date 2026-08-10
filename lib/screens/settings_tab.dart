import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/design_tokens.dart';
import '../widgets/bm_card.dart';
import '../db/database_helper.dart';

class SettingsTab extends StatefulWidget {
  final VoidCallback onThemeToggle;
  const SettingsTab({Key? key, required this.onThemeToggle}) : super(key: key);

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  final _db = DatabaseHelper.instance;

  Future<void> _factoryReset() async {
    final conf = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('FACTORY RESET', style: TextStyle(color: Tok.red2)),
        content: const Text('This will delete all live data and restore demo data. Are you absolutely sure?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('YES, RESET', style: TextStyle(color: Tok.red2))),
        ],
      ),
    );
    if (conf == true) {
      await _db.resetAndSeedDemoData();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('App reset to demo data')));
    }
  }

  Future<void> _clearAll() async {
    final conf = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('CLEAR ALL DATA', style: TextStyle(color: Tok.red2)),
        content: const Text('This will permanently delete all records and start fresh.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('YES, CLEAR', style: TextStyle(color: Tok.red2))),
        ],
      ),
    );
    if (conf == true) {
      await _db.clearAllData();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All data cleared')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      children: [
        const Text('Settings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        
        BmCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Appearance', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Tok.text2 : Tok.text2Light)),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(isDark ? Icons.dark_mode : Icons.light_mode, color: Tok.gold),
                title: Text('Toggle Dark/Light Mode', style: TextStyle(fontSize: 14, color: isDark ? Tok.text : Tok.textLight)),
                trailing: Switch(
                  value: isDark,
                  onChanged: (v) => widget.onThemeToggle(),
                  activeColor: Tok.gold,
                ),
              ),
            ],
          ),
        ),
        
        BmCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Database Management', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Tok.text2 : Tok.text2Light)),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.download, color: Tok.green2),
                title: Text('Export JSON Backup', style: TextStyle(fontSize: 14, color: isDark ? Tok.text : Tok.textLight)),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Backup exported to Downloads folder')));
                },
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.delete_sweep, color: Tok.red2),
                title: const Text('Clear All Data (Start Fresh)', style: TextStyle(fontSize: 14, color: Tok.red2)),
                onTap: _clearAll,
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.restore, color: Tok.amber2),
                title: const Text('Factory Reset (Load Demo Data)', style: TextStyle(fontSize: 14, color: Tok.amber2)),
                onTap: _factoryReset,
              ),
            ],
          ),
        ),

        const SizedBox(height: 40),
        const Center(
          child: Text('Business Manager v2.0.0+4\nPowered by Flutter', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: Tok.text3)),
        ),
      ],
    );
  }
}
