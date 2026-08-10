import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/design_tokens.dart';
import '../main.dart';
import '../theme/app_theme.dart';
import 'pin_lock_screen.dart';
import 'home_tab.dart';
import 'farm_tab.dart';
import 'shop_tab.dart';
import 'finance_tab.dart';
import 'settings_tab.dart';

import '../services/google_drive_service.dart';
import '../services/update_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late final List<Widget> _tabs;
  final GoogleDriveService _driveService = GoogleDriveService();
  final UpdateService _updateService = UpdateService();
  bool _isSignedIn = false;
  String _lastSyncStr = 'never';

  @override
  void initState() {
    super.initState();
    _tabs = [
      const HomeTab(),
      const FarmTab(),
      const ShopTab(),
      const FinanceTab(),
      SettingsTab(onThemeToggle: () {
        final mode = themeNotifier.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
        themeNotifier.value = mode;
      }),
    ];
    
    // Check for updates shortly after app starts
    Future.delayed(const Duration(seconds: 3), _checkForUpdates);
  }

  Future<void> _checkForUpdates() async {
    final updateInfo = await _updateService.checkForUpdates();
    if (updateInfo != null && mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Update Available"),
          content: Text("Version \${updateInfo.latestVersion} is available. Would you like to download it?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Later")),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _updateService.launchUpdateUrl(updateInfo.downloadUrl);
              }, 
              child: const Text("Update Now"),
            ),
          ],
        ),
      );
    }
  }

  void _showSyncDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Google Drive Sync'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_isSignedIn ? 'Status: Signed in' : 'Status: Not signed in'),
                  const SizedBox(height: 15),
                  if (!_isSignedIn)
                    ElevatedButton(
                      onPressed: () async {
                        final success = await _driveService.signIn();
                        if (success) {
                          setDialogState(() => _isSignedIn = true);
                          setState(() => _isSignedIn = true);
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Sign-in failed. Please ensure the SHA-1 is registered in Google Cloud.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      child: const Text('Sign in with Google'),
                    ),
                  if (_isSignedIn) ...[
                    ElevatedButton.icon(
                      onPressed: () async {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Downloading database...')));
                        try {
                          final success = await _driveService.downloadDatabase('business.db');
                          if (success && mounted) {
                            setState(() => _lastSyncStr = 'just now');
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Download complete. Restart app to view changes.')));
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Error: \$e'),
                              backgroundColor: Colors.red,
                            ));
                          }
                        }
                      },
                      icon: const Icon(Icons.cloud_download),
                      label: const Text('Download from Desktop'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () async {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Uploading database...')));
                        try {
                          final success = await _driveService.uploadDatabase('business.db');
                          if (success && mounted) {
                            setState(() => _lastSyncStr = 'just now');
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload complete! Desktop can now sync.')));
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Error: \$e'),
                              backgroundColor: Colors.red,
                            ));
                          }
                        }
                      },
                      icon: const Icon(Icons.cloud_upload),
                      label: const Text('Upload changes to Cloud'),
                    ),
                  ]
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  final List<String> _titles = [
    'HI-TECH & AL-KABEER',
    'HI-TECH Goat Farm',
    'AL-KABEER Mutton',
    'Profit & Loss',
    'Settings',
  ];

  void _lockApp() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const _RelockWrapper()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, d MMMM yyyy').format(now);

    return Scaffold(
      backgroundColor: isDark ? Tok.bg : Tok.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            // App Header
            Container(
              color: isDark ? Tok.bg : Tok.bgLight,
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: isDark ? Tok.border : Tok.borderLight)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _titles[_currentIndex],
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Tok.gold2,
                          letterSpacing: 0.3,
                        ),
                      ),
                      Row(
                        children: [
                          _HeaderBtn(icon: Icons.lock, onTap: _lockApp),
                          const SizedBox(width: 6),
                          _HeaderBtn(icon: Icons.sync, onTap: _showSyncDialog),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '\$dateStr · last sync: \$_lastSyncStr',
                    style: TextStyle(fontSize: 11, color: isDark ? Tok.text3 : Tok.text3Light),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: Tok.tealBg,
                      border: Border.all(color: Tok.teal.withOpacity(0.25)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _PulseDot(),
                        const SizedBox(width: 5),
                        Text(
                          'Live sync · Owner v2.0',
                          style: TextStyle(fontSize: 10, color: Tok.teal2, fontWeight: FontWeight.w500, letterSpacing: 0.1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: _tabs,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? Tok.bg : Tok.cardLight,
          border: Border(top: BorderSide(color: isDark ? Tok.border : Tok.borderLight)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Tok.gold,
          unselectedItemColor: isDark ? Tok.text3 : Tok.text3Light,
          selectedFontSize: 9,
          unselectedFontSize: 9,
          iconSize: 20,
          items: const [
            BottomNavigationBarItem(icon: Text('🏠', style: TextStyle(fontSize: 20)), label: 'Home'),
            BottomNavigationBarItem(icon: Text('🐐', style: TextStyle(fontSize: 20)), label: 'Farm'),
            BottomNavigationBarItem(icon: Text('🥩', style: TextStyle(fontSize: 20)), label: 'Shop'),
            BottomNavigationBarItem(icon: Text('📈', style: TextStyle(fontSize: 20)), label: 'Finance'),
            BottomNavigationBarItem(icon: Text('⚙️', style: TextStyle(fontSize: 20)), label: 'Settings'),
          ],
        ),
      ),
    );
  }
}

class _HeaderBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HeaderBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark ? Tok.card2 : Tok.card2Light,
          border: Border.all(color: isDark ? Tok.border2 : Tok.border2Light),
        ),
        child: Icon(icon, size: 15, color: isDark ? Tok.text2 : Tok.text2Light),
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final v = (1.0 - (_ctrl.value * 2 - 1).abs());
        return Opacity(
          opacity: 0.4 + 0.6 * v,
          child: Transform.scale(
            scale: 0.85 + 0.15 * v,
            child: Container(
              width: 6, height: 6,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Tok.teal2),
            ),
          ),
        );
      },
    );
  }
}

class _RelockWrapper extends StatelessWidget {
  const _RelockWrapper();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: _RelockGate(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class _RelockGate extends StatefulWidget {
  const _RelockGate();

  @override
  State<_RelockGate> createState() => _RelockGateState();
}

class _RelockGateState extends State<_RelockGate> {
  bool _unlocked = false;

  @override
  Widget build(BuildContext context) {
    // Simply restart the app flow
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, mode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: mode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: _unlocked
              ? const MainScreen()
              : PinLockScreen(onUnlock: () => setState(() => _unlocked = true)),
        );
      },
    );
  }
}
