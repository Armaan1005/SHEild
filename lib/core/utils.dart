import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

class AppUtils {
  /// Make a phone call
  static Future<void> makePhoneCall(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  /// Send SMS with pre-composed message
  static Future<void> sendEmergencySMS({
    required List<String> numbers,
    required String message,
  }) async {
    for (final number in numbers) {
      final uri = Uri(
        scheme: 'sms',
        path: number,
        queryParameters: {'body': message},
      );
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        break; // Open SMS app once with first number
      }
    }
  }

  /// Build emergency SMS message with location
  static String buildEmergencyMessage({double? lat, double? lng}) {
    final locationStr = lat != null && lng != null
        ? '\n📍 Location: https://www.google.com/maps?q=$lat,$lng'
        : '';
    return '🚨 EMERGENCY ALERT from SHEild!\n\nI need help immediately. This is an automated safety alert.$locationStr\n\nPlease call me or send help!';
  }

  /// Open a URL in browser
  static Future<void> openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// Open location in Google Maps
  static Future<void> openInGoogleMaps(double lat, double lng) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    await openUrl(url);
  }

  /// Get current position
  static Future<Position?> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  /// Format coordinates
  static String formatCoordinate(double value, {int decimals = 6}) {
    return value.toStringAsFixed(decimals);
  }

  /// Get greeting based on time of day
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  /// Format duration from seconds
  static String formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  /// Haptic feedback helpers
  static void hapticLight() => HapticFeedback.lightImpact();
  static void hapticMedium() => HapticFeedback.mediumImpact();
  static void hapticHeavy() => HapticFeedback.heavyImpact();
  static void hapticSOS() {
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 100), () {
      HapticFeedback.heavyImpact();
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      HapticFeedback.heavyImpact();
    });
  }
}
