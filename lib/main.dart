import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'features/splash/splash_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/home/home_screen.dart';
import 'features/sos/sos_screen.dart';
import 'features/location/location_screen.dart';
import 'features/stealth/stealth_screen.dart';
import 'features/recorder/recorder_screen.dart';
import 'features/fake_call/fake_call_screen.dart';
import 'features/safety_tips/safety_tips_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/trusted_contacts/trusted_contacts_screen.dart';
import 'features/journey_timer/journey_timer_screen.dart';
import 'features/safe_walk/safe_walk_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0A0A0A),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    const ProviderScope(
      child: SHEildApp(),
    ),
  );
}

class SHEildApp extends StatelessWidget {
  const SHEildApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SHEild',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/home': (context) => const HomeScreen(),
        '/sos': (context) => const SOSScreen(),
        '/location': (context) => const LocationScreen(),
        '/stealth': (context) => const StealthScreen(),
        '/recorder': (context) => const RecorderScreen(),
        '/fake-call': (context) => const FakeCallScreen(),
        '/safety-tips': (context) => const SafetyTipsScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/trusted-contacts': (context) => const TrustedContactsScreen(),
        '/journey-timer': (context) => const JourneyTimerScreen(),
        '/safe-walk': (context) => const SafeWalkScreen(),
      },
    );
  }
}
