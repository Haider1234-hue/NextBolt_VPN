import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:nextboltvpn/app.dart';
import 'package:nextboltvpn/services/vpn_service.dart';
import 'package:nextboltvpn/features/home/home_controller.dart';
import 'package:nextboltvpn/core/constants/app_strings.dart';

void main() {
  testWidgets('Splash screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => VpnService()),
          ChangeNotifierProxyProvider<VpnService, HomeController>(
            create: (ctx) => HomeController(ctx.read<VpnService>()),
            update: (ctx, vpn, prev) => prev!..updateVpnService(vpn),
          ),
        ],
        child: const NextBoltApp(),
      ),
    );

    // Verify that the splash screen shows the app name.
    expect(find.text(AppStrings.appName), findsOneWidget);

    // Settle splash screen timer and onboarding transitions
    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pumpAndSettle();
  });
}
