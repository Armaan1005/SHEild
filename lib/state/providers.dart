import 'dart:async';
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
      stealthPin:
          prefs.getString(AppConstants.keyStealthPin) ?? '1234',
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
      if (acceleration > AppConstants.shakeThreshold * AppConstants.shakeThreshold) {
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
