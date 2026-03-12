import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../core/constants.dart';

import '../core/utils.dart';

// ============ Location Providers ============

final locationProvider = StateNotifierProvider<LocationNotifier, LocationState>(
  (ref) => LocationNotifier(),
);

class LocationState {
  final double? latitude;
  final double? longitude;
  final bool isTracking;
  final String? error;

  const LocationState({
    this.latitude,
    this.longitude,
    this.isTracking = false,
    this.error,
  });

  LocationState copyWith({
    double? latitude,
    double? longitude,
    bool? isTracking,
    String? error,
  }) {
    return LocationState(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isTracking: isTracking ?? this.isTracking,
      error: error ?? this.error,
    );
  }
}

class LocationNotifier extends StateNotifier<LocationState> {
  StreamSubscription<Position>? _subscription;

  LocationNotifier() : super(const LocationState());

  Future<void> startTracking() async {
    final position = await AppUtils.getCurrentPosition();
    if (position != null) {
      state = state.copyWith(
        latitude: position.latitude,
        longitude: position.longitude,
        isTracking: true,
      );

      _subscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5,
        ),
      ).listen((pos) {
        state = state.copyWith(
          latitude: pos.latitude,
          longitude: pos.longitude,
        );
      });
    } else {
      state = state.copyWith(error: 'Location permission denied');
    }
  }

  void stopTracking() {
    _subscription?.cancel();
    state = state.copyWith(isTracking: false);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

// ============ SOS Providers ============

final sosActiveProvider = StateProvider<bool>((ref) => false);

final recordingProvider =
    StateNotifierProvider<RecordingNotifier, RecordingState>(
  (ref) => RecordingNotifier(),
);

class RecordingState {
  final bool isRecording;
  final int durationSeconds;
  final List<RecordingItem> recordings;

  const RecordingState({
    this.isRecording = false,
    this.durationSeconds = 0,
    this.recordings = const [],
  });

  RecordingState copyWith({
    bool? isRecording,
    int? durationSeconds,
    List<RecordingItem>? recordings,
  }) {
    return RecordingState(
      isRecording: isRecording ?? this.isRecording,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      recordings: recordings ?? this.recordings,
    );
  }
}

class RecordingItem {
  final String name;
  final String date;
  final String duration;
  final String path;

  const RecordingItem({
    required this.name,
    required this.date,
    required this.duration,
    required this.path,
  });
}

class RecordingNotifier extends StateNotifier<RecordingState> {
  Timer? _timer;

  RecordingNotifier() : super(const RecordingState());

  void startRecording() {
    state = state.copyWith(isRecording: true, durationSeconds: 0);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(durationSeconds: state.durationSeconds + 1);
    });
  }

  void stopRecording() {
    _timer?.cancel();
    final newRecording = RecordingItem(
      name: 'Recording ${state.recordings.length + 1}',
      date: DateTime.now().toString().substring(0, 16),
      duration: AppUtils.formatDuration(state.durationSeconds),
      path: '/recordings/rec_${state.recordings.length + 1}.m4a',
    );
    state = state.copyWith(
      isRecording: false,
      durationSeconds: 0,
      recordings: [...state.recordings, newRecording],
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// ============ Settings Providers ============

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) => SettingsNotifier(),
);

class SettingsState {
  final String emergencyContact;
  final String emergencyName;
  final String stealthPin;
  final String fakeCallerName;
  final bool shakeEnabled;
  final bool voiceTriggerEnabled;
  final bool isLoaded;

  const SettingsState({
    this.emergencyContact = '',
    this.emergencyName = 'Emergency Contact',
    this.stealthPin = '1234',
    this.fakeCallerName = 'Mom',
    this.shakeEnabled = true,
    this.voiceTriggerEnabled = false,
    this.isLoaded = false,
  });

  SettingsState copyWith({
    String? emergencyContact,
    String? emergencyName,
    String? stealthPin,
    String? fakeCallerName,
    bool? shakeEnabled,
    bool? voiceTriggerEnabled,
    bool? isLoaded,
  }) {
    return SettingsState(
      emergencyContact: emergencyContact ?? this.emergencyContact,
      emergencyName: emergencyName ?? this.emergencyName,
      stealthPin: stealthPin ?? this.stealthPin,
      fakeCallerName: fakeCallerName ?? this.fakeCallerName,
      shakeEnabled: shakeEnabled ?? this.shakeEnabled,
      voiceTriggerEnabled: voiceTriggerEnabled ?? this.voiceTriggerEnabled,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    state = SettingsState(
      emergencyContact:
          prefs.getString(AppConstants.keyEmergencyContact) ?? '',
      emergencyName:
          prefs.getString(AppConstants.keyEmergencyName) ?? 'Emergency Contact',
      stealthPin: prefs.getString(AppConstants.keyStealthPin) ?? '1234',
      fakeCallerName:
          prefs.getString(AppConstants.keyFakeCallerName) ?? 'Mom',
      shakeEnabled: prefs.getBool(AppConstants.keyShakeEnabled) ?? true,
      voiceTriggerEnabled:
          prefs.getBool(AppConstants.keyVoiceTriggerEnabled) ?? false,
      isLoaded: true,
    );
  }

  Future<void> updateEmergencyContact(String name, String number) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyEmergencyName, name);
    await prefs.setString(AppConstants.keyEmergencyContact, number);
    state = state.copyWith(emergencyName: name, emergencyContact: number);
  }

  Future<void> updateStealthPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyStealthPin, pin);
    state = state.copyWith(stealthPin: pin);
  }

  Future<void> updateFakeCallerName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyFakeCallerName, name);
    state = state.copyWith(fakeCallerName: name);
  }

  Future<void> toggleShake(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyShakeEnabled, value);
    state = state.copyWith(shakeEnabled: value);
  }

  Future<void> toggleVoiceTrigger(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyVoiceTriggerEnabled, value);
    state = state.copyWith(voiceTriggerEnabled: value);
  }


}

// ============ Trusted Contacts Provider ============

final trustedContactsProvider =
    StateNotifierProvider<TrustedContactsNotifier, List<TrustedContact>>(
  (ref) => TrustedContactsNotifier(),
);

class TrustedContact {
  final String name;
  final String phone;

  const TrustedContact({required this.name, required this.phone});

  Map<String, String> toJson() => {'name': name, 'phone': phone};

  factory TrustedContact.fromJson(Map<String, dynamic> json) {
    return TrustedContact(
      name: json['name'] as String,
      phone: json['phone'] as String,
    );
  }
}

class TrustedContactsNotifier extends StateNotifier<List<TrustedContact>> {
  TrustedContactsNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('trusted_contacts');
    if (data != null) {
      final list = jsonDecode(data) as List;
      state = list.map((e) => TrustedContact.fromJson(e)).toList();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(state.map((e) => e.toJson()).toList());
    await prefs.setString('trusted_contacts', data);
  }

  Future<void> addContact(TrustedContact contact) async {
    if (state.length >= 5) return;
    state = [...state, contact];
    await _save();
  }

  Future<void> removeContact(int index) async {
    final list = [...state];
    list.removeAt(index);
    state = list;
    await _save();
  }
}

// ============ Journey Timer Provider ============

final journeyTimerProvider =
    StateNotifierProvider<JourneyTimerNotifier, JourneyTimerState>(
  (ref) => JourneyTimerNotifier(),
);

class JourneyTimerState {
  final bool isActive;
  final int totalSeconds;
  final int remainingSeconds;
  final String destination;
  final bool hasExpired;

  const JourneyTimerState({
    this.isActive = false,
    this.totalSeconds = 0,
    this.remainingSeconds = 0,
    this.destination = '',
    this.hasExpired = false,
  });

  JourneyTimerState copyWith({
    bool? isActive,
    int? totalSeconds,
    int? remainingSeconds,
    String? destination,
    bool? hasExpired,
  }) {
    return JourneyTimerState(
      isActive: isActive ?? this.isActive,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      destination: destination ?? this.destination,
      hasExpired: hasExpired ?? this.hasExpired,
    );
  }
}

class JourneyTimerNotifier extends StateNotifier<JourneyTimerState> {
  Timer? _timer;

  JourneyTimerNotifier() : super(const JourneyTimerState());

  void startTimer({required int minutes, required String destination}) {
    _timer?.cancel();
    final totalSec = minutes * 60;
    state = JourneyTimerState(
      isActive: true,
      totalSeconds: totalSec,
      remainingSeconds: totalSec,
      destination: destination,
    );
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.remainingSeconds <= 1) {
        _timer?.cancel();
        state = state.copyWith(remainingSeconds: 0, hasExpired: true, isActive: false);
        AppUtils.hapticSOS();
      } else {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      }
    });
  }

  void markSafe() {
    _timer?.cancel();
    state = const JourneyTimerState();
  }

  void cancelTimer() {
    _timer?.cancel();
    state = const JourneyTimerState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// ============ Danger Zones Provider ============

final dangerZonesProvider =
    StateNotifierProvider<DangerZonesNotifier, List<DangerZone>>(
  (ref) => DangerZonesNotifier(),
);

class DangerZone {
  final double latitude;
  final double longitude;
  final String label;

  const DangerZone({
    required this.latitude,
    required this.longitude,
    required this.label,
  });

  Map<String, dynamic> toJson() =>
      {'lat': latitude, 'lng': longitude, 'label': label};

  factory DangerZone.fromJson(Map<String, dynamic> json) {
    return DangerZone(
      latitude: json['lat'] as double,
      longitude: json['lng'] as double,
      label: json['label'] as String,
    );
  }
}

class DangerZonesNotifier extends StateNotifier<List<DangerZone>> {
  DangerZonesNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('danger_zones');
    if (data != null) {
      final list = jsonDecode(data) as List;
      state = list.map((e) => DangerZone.fromJson(e)).toList();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(state.map((e) => e.toJson()).toList());
    await prefs.setString('danger_zones', data);
  }

  Future<void> addZone(DangerZone zone) async {
    state = [...state, zone];
    await _save();
  }

  Future<void> removeZone(int index) async {
    final list = [...state];
    list.removeAt(index);
    state = list;
    await _save();
  }
}

// ============ Panic Pattern Provider ============

final panicPatternProvider =
    StateNotifierProvider<PanicPatternNotifier, PanicPatternState>(
  (ref) => PanicPatternNotifier(),
);

class PanicPatternState {
  final bool isEnabled;
  final int requiredTaps;
  final int tapCount;
  final bool isTriggered;

  const PanicPatternState({
    this.isEnabled = true,
    this.requiredTaps = 5,
    this.tapCount = 0,
    this.isTriggered = false,
  });

  PanicPatternState copyWith({
    bool? isEnabled,
    int? requiredTaps,
    int? tapCount,
    bool? isTriggered,
  }) {
    return PanicPatternState(
      isEnabled: isEnabled ?? this.isEnabled,
      requiredTaps: requiredTaps ?? this.requiredTaps,
      tapCount: tapCount ?? this.tapCount,
      isTriggered: isTriggered ?? this.isTriggered,
    );
  }
}

class PanicPatternNotifier extends StateNotifier<PanicPatternState> {
  Timer? _resetTimer;

  PanicPatternNotifier() : super(const PanicPatternState());

  bool registerTap() {
    _resetTimer?.cancel();
    final newCount = state.tapCount + 1;

    if (newCount >= state.requiredTaps) {
      state = state.copyWith(tapCount: 0, isTriggered: true);
      AppUtils.hapticSOS();
      // Reset triggered state after a moment
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          state = state.copyWith(isTriggered: false);
        }
      });
      return true;
    }

    state = state.copyWith(tapCount: newCount);

    // Reset tap count after 2 seconds of no taps
    _resetTimer = Timer(const Duration(seconds: 2), () {
      state = state.copyWith(tapCount: 0);
    });

    return false;
  }

  void reset() {
    _resetTimer?.cancel();
    state = state.copyWith(tapCount: 0, isTriggered: false);
  }
}

// ============ Safe Walk Provider ============

final safeWalkProvider =
    StateNotifierProvider<SafeWalkNotifier, SafeWalkState>(
  (ref) => SafeWalkNotifier(),
);

class SafeWalkState {
  final bool isActive;
  final int durationSeconds;
  final bool phoneDropped;

  const SafeWalkState({
    this.isActive = false,
    this.durationSeconds = 0,
    this.phoneDropped = false,
  });

  SafeWalkState copyWith({
    bool? isActive,
    int? durationSeconds,
    bool? phoneDropped,
  }) {
    return SafeWalkState(
      isActive: isActive ?? this.isActive,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      phoneDropped: phoneDropped ?? this.phoneDropped,
    );
  }
}

class SafeWalkNotifier extends StateNotifier<SafeWalkState> {
  Timer? _timer;
  StreamSubscription? _accelSubscription;

  SafeWalkNotifier() : super(const SafeWalkState());

  void startWalk() {
    state = const SafeWalkState(isActive: true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(durationSeconds: state.durationSeconds + 1);
    });

    // Monitor phone orientation for drop detection
    _accelSubscription = accelerometerEventStream().listen((event) {
      // If phone goes mostly horizontal (z-axis near 0, large x/y)
      // and there's a sudden acceleration spike, it might be dropped
      final zAbs = event.z.abs();
      final xyMag = event.x * event.x + event.y * event.y;
      if (zAbs < 2.0 && xyMag > 150) {
        state = state.copyWith(phoneDropped: true);
        AppUtils.hapticSOS();
      }
    });
  }

  void stopWalk() {
    _timer?.cancel();
    _accelSubscription?.cancel();
    state = const SafeWalkState();
  }

  void dismissDropAlert() {
    state = state.copyWith(phoneDropped: false);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _accelSubscription?.cancel();
    super.dispose();
  }
}

// ============ Battery Monitor Provider ============

final batteryProvider = StateNotifierProvider<BatteryNotifier, BatteryState>(
  (ref) => BatteryNotifier(),
);

class BatteryState {
  final int level;
  final bool isLow;
  final bool alertSent;

  const BatteryState({
    this.level = 100,
    this.isLow = false,
    this.alertSent = false,
  });

  BatteryState copyWith({int? level, bool? isLow, bool? alertSent}) {
    return BatteryState(
      level: level ?? this.level,
      isLow: isLow ?? this.isLow,
      alertSent: alertSent ?? this.alertSent,
    );
  }
}

class BatteryNotifier extends StateNotifier<BatteryState> {
  BatteryNotifier() : super(const BatteryState());

  void updateLevel(int level) {
    state = state.copyWith(
      level: level,
      isLow: level <= 10,
    );
  }

  void markAlertSent() {
    state = state.copyWith(alertSent: true);
  }
}

// ============ Shake Detection Provider ============

final shakeDetectorProvider = Provider<ShakeDetector>((ref) {
  return ShakeDetector();
});

class ShakeDetector {
  StreamSubscription? _subscription;
  DateTime _lastShakeTime = DateTime.now();

  void startListening(Function onShake) {
    _subscription = accelerometerEventStream().listen((event) {
      final acceleration =
          event.x * event.x + event.y * event.y + event.z * event.z;
      if (acceleration >
          AppConstants.shakeThreshold * AppConstants.shakeThreshold) {
        final now = DateTime.now();
        if (now.difference(_lastShakeTime).inMilliseconds >
            AppConstants.shakeCooldownMs) {
          _lastShakeTime = now;
          onShake();
        }
      }
    });
  }

  void stopListening() {
    _subscription?.cancel();
  }
}
