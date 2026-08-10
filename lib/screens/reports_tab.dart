import 'package:flutter/material.dart';
import '../widgets/glass_card.dart';
import '../theme/app_theme.dart';

class ReportsTab extends StatelessWidget {
  const ReportsTab({Key? key}) : super(key: key);

  void _triggerReport(BuildContext context, String reportName) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('📄 $reportName Triggered')));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Instant PDF Reports', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.goldAccent, fontFamily: 'serif')),
        const SizedBox(height: 16),
        
        _buildReportTile(context, Icons.picture_as_pdf, 'Monthly Cash Flow Statement', 'PDF Register Export', () => _triggerReport(context, 'Cashflow PDF')),
        const SizedBox(height: 12),
        _buildReportTile(context, Icons.receipt_long, 'Goat Sales Register', 'PDF Register Export', () => _triggerReport(context, 'Sales Register')),
        const SizedBox(height: 12),
        _buildReportTile(context, Icons.inventory, 'Farm Inventory Status', 'PDF Register Export', () => _triggerReport(context, 'Inventory Report')),
      ],
    );
  }

  Widget _buildReportTile(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        child: Row(
          children: [
            Icon(icon, size: 36, color: AppTheme.goldAccent),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.download, color: AppTheme.goldAccent),
          ],
        ),
      ),
    );
  }
}
