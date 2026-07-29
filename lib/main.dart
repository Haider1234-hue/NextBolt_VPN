import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'features/home/home_controller.dart';
import 'services/iap_service.dart';
import 'services/settings_service.dart';
import 'services/vpn_service.dart';

const _deviceTypeChannel = MethodChannel(
  'com.torcia.secure.vpn.proxy/device_type',
);

void main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();

  // physicalSize isn't reliable until the first frame has been laid out, so
  // decide phone-vs-tablet (and lock/free orientation accordingly) after it.
  binding.addPostFrameCallback((_) async {
    // TV has no accelerometer and is always landscape; a shortest-side-dp
    // check alone can't tell it apart from a phone (some TV profiles report
    // well under 600dp), and forcing a portrait lock on it just pillarboxes
    // the app in a portrait box on the landscape panel. Ask the platform
    // directly instead of guessing from size.
    var isTelevision = false;
    try {
      isTelevision =
          await _deviceTypeChannel.invokeMethod<bool>('isTelevision') ??
          false;
    } on PlatformException {
      isTelevision = false;
    }

    if (isTelevision) {
      await SystemChrome.setPreferredOrientations([]);
      return;
    }

    final view = binding.platformDispatcher.views.first;
    final shortestSideDp = view.physicalSize.shortestSide / view.devicePixelRatio;
    final isTablet = shortestSideDp >= 600;

    await SystemChrome.setPreferredOrientations(
      // Tablets: clear the restriction entirely (`[]`) instead of listing
      // all four orientations explicitly — on landscape-natural tablets,
      // requesting DeviceOrientation.values maps to an Android orientation
      // constant that rotates relative to the device's natural orientation
      // and renders the whole canvas sideways. An empty list is Flutter's
      // documented way to say "no preference" without that transform.
      isTablet
          ? []
          : [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
    );
  });

  // Dark status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsService()),
        ChangeNotifierProxyProvider<SettingsService, VpnService>(
          create: (ctx) => VpnService(ctx.read<SettingsService>()),
          update: (ctx, settings, prev) => prev!..updateSettings(settings),
        ),
        ChangeNotifierProxyProvider<VpnService, IapService>(
          create: (ctx) => IapService(ctx.read<VpnService>()),
          update: (ctx, vpn, prev) => prev!..updateVpnService(vpn),
        ),
        ChangeNotifierProxyProvider<VpnService, HomeController>(
          create: (ctx) => HomeController(ctx.read<VpnService>()),
          update: (ctx, vpn, prev) => prev!..updateVpnService(vpn),
        ),
      ],
      child: const NextBoltApp(),
    ),
  );
}