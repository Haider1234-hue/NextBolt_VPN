import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/home/home_screen.dart';
import 'features/servers/server_list_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/premium/premium_screen.dart';

class NextBoltApp extends StatelessWidget {
  const NextBoltApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NextBolt VPN',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/home': (context) => const HomeScreen(),
        '/servers': (context) => const ServerListScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/premium': (context) => const PremiumScreen(),
      },
    );
  }
}