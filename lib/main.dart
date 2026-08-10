import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'screens/pin_lock_screen.dart';
import 'screens/main_screen.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  
  // Load saved theme
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('dark_mode') ?? true;
  themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
  
  runApp(const BusinessManagerApp());
}

class BusinessManagerApp extends StatelessWidget {
  const BusinessManagerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'HI-TECH & AL-KABEER — Business Manager',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: const AppGate(),
        );
      },
    );
  }
}

class AppGate extends StatefulWidget {
  const AppGate({Key? key}) : super(key: key);

  @override
  State<AppGate> createState() => _AppGateState();
}

class _AppGateState extends State<AppGate> {
  bool _unlocked = false;

  @override
  Widget build(BuildContext context) {
    if (!_unlocked) {
      return PinLockScreen(onUnlock: () => setState(() => _unlocked = true));
    }
    return const MainScreen();
  }
}
