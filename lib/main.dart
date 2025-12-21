import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home_screen.dart';
import 'utils/theme.dart';
import 'utils/localization.dart';

import 'services/auth_service.dart';
import 'screens/auth/app_lock_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  bool _isDarkMode = false;
  Locale _locale = Locale('fr', '');
  final AuthService _authService = AuthService();
  bool _isLocked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSettings();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Vérifier si on doit verrouiller l'application
      if (!_isLocked) {
        final isLoggedIn = await _authService.isLoggedIn();
        if (isLoggedIn) {
          final hasLock = await _authService.hasAppLock();
          if (hasLock) {
            _showAppLock();
            // TODO: Navigate to App Lock Screen
            // Note: Since we don't have a global NavigatorContext easily accessible here without a key,
            // we will handle this by pushing a new route if we can, or setting a state variable.
            // A better approach usually involves a GlobalKey<NavigatorState>.
          }
        }
      }
    }
  }

  // Utiliser une GlobalKey pour la navigation
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  void _showAppLock() {
    setState(() {
      _isLocked = true;
    });
    _navigatorKey.currentState
        ?.push(
      MaterialPageRoute(
        builder: (ctx) =>
            WillPopScope(onWillPop: () async => false, child: AppLockScreen()),
      ),
    )
        .then((_) {
      setState(() {
        _isLocked = false;
      });
    });
  }

  _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      String languageCode = prefs.getString('languageCode') ?? 'fr';
      _locale = Locale(languageCode, '');
    });
  }

  void _toggleTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  void _changeLanguage(String languageCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _locale = Locale(languageCode, '');
    });
    await prefs.setString('languageCode', languageCode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Troov',
      theme: _isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      locale: _locale,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('fr', ''),
        Locale('en', ''),
        Locale('es', ''),
      ],
      home: SplashScreen(),
      routes: {
        '/welcome': (context) => WelcomeScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomeScreen(
              onThemeToggle: _toggleTheme,
              onLanguageChange: _changeLanguage,
              isDarkMode: _isDarkMode,
              currentLocale: _locale,
            ),
      },
    );
  }
}
