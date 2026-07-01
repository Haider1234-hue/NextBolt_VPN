import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/home/home_screen.dart';
import 'features/servers/server_list_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/premium/premium_screen.dart';
import 'services/settings_service.dart';

class NextBoltApp extends StatelessWidget {
  const NextBoltApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsService>(
      builder: (context, settings, _) {
        return MaterialApp(
          title: 'NextBolt VPN',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          locale: settings.locale,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('es'),
            Locale('de'),
            Locale('fr'),
          ],
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
      },
    );
  }
}
