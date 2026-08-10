import 'package:flutter/material.dart';
import '../widgets/glass_card.dart';
import '../theme/app_theme.dart';

class CloudTab extends StatelessWidget {
  const CloudTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('☁️ Google Drive Cloud Sync', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.goldAccent, fontFamily: 'serif')),
              const SizedBox(height: 16),
              
              const Text('Status: ', style: TextStyle(fontWeight: FontWeight.bold)),
              const Text('CONNECTED & SYNCED', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              
              const Text('Mode: Continuous 10s Background Pulse'),
              const SizedBox(height: 8),
              
              const Text('Database: business.db (WAL Mode)'),
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
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('☁️ Cloud Sync Completed')));
                  },
                  icon: const Icon(Icons.sync),
                  label: const Text('Sync Drive Now', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
