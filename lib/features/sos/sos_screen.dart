import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../state/providers.dart';

class SOSScreen extends ConsumerStatefulWidget {
  const SOSScreen({super.key});

  @override
  ConsumerState<SOSScreen> createState() => _SOSScreenState();
}

class _SOSScreenState extends ConsumerState<SOSScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _locationLoaded = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Auto-start recording and location
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sosActiveProvider.notifier).state = true;
      ref.read(recordingProvider.notifier).startRecording();
      _loadLocation();
    });
  }

  Future<void> _loadLocation() async {
    await ref.read(locationProvider.notifier).startTracking();
    if (mounted) setState(() => _locationLoaded = true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _deactivateSOS() {
    ref.read(sosActiveProvider.notifier).state = false;
    final recording = ref.read(recordingProvider);
    if (recording.isRecording) {
      ref.read(recordingProvider.notifier).stopRecording();
    }
    ref.read(locationProvider.notifier).stopTracking();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final location = ref.watch(locationProvider);
    final recording = ref.watch(recordingProvider);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: _deactivateSOS,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.close,
                          color: AppColors.text, size: 22),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _pulseAnimation.value,
                        child: const Row(
                          children: [
                            Icon(Icons.emergency, color: AppColors.accent,
                                size: 20),
                            SizedBox(width: 8),
                            Text(
                              'SOS ACTIVE',
                              style: TextStyle(
                                color: AppColors.accent,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 42),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Alert card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.accent.withValues(alpha: 0.2),
                            AppColors.accent.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              color: AppColors.accent, size: 48),
                          const SizedBox(height: 12),
                          const Text(
                            'Emergency Alert Active',
                            style: TextStyle(
                              color: AppColors.accent,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Recording evidence • Location tracked',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Recording indicator
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: recording.isRecording
                                  ? AppColors.accent
                                  : AppColors.textSecondary,
                              boxShadow: recording.isRecording
                                  ? [
                                      BoxShadow(
                                        color: AppColors.accent
                                            .withValues(alpha: 0.5),
                                        blurRadius: 8,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  recording.isRecording
                                      ? 'Recording Audio...'
                                      : 'Recording Stopped',
                                  style: const TextStyle(
                                    color: AppColors.text,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Duration: ${AppUtils.formatDuration(recording.durationSeconds)}',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              if (recording.isRecording) {
                                ref
                                    .read(recordingProvider.notifier)
                                    .stopRecording();
                              } else {
                                ref
                                    .read(recordingProvider.notifier)
                                    .startRecording();
                              }
                            },
                            icon: Icon(
                              recording.isRecording
                                  ? Icons.stop_circle
                                  : Icons.play_circle,
                              color: AppColors.accent,
                              size: 32,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Location / Map
                    Container(
                      height: 220,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.surfaceLight,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _locationLoaded &&
                              location.latitude != null &&
                              location.longitude != null
                          ? FlutterMap(
                              options: MapOptions(
                                initialCenter: LatLng(
                                    location.latitude!, location.longitude!),
                                initialZoom: 16,
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'com.sheild.app',
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: LatLng(location.latitude!,
                                          location.longitude!),
                                      width: 40,
                                      height: 40,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.accent,
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.accent
                                                  .withValues(alpha: 0.5),
                                              blurRadius: 12,
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.person_pin,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const CircularProgressIndicator(
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    location.error ?? 'Getting location...',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                    const SizedBox(height: 12),

                    // Coordinates
                    if (location.latitude != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.my_location,
                                color: AppColors.primary, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              '${AppUtils.formatCoordinate(location.latitude!, decimals: 4)}, ${AppUtils.formatCoordinate(location.longitude!, decimals: 4)}',
                              style: const TextStyle(
                                color: AppColors.text,
                                fontSize: 13,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.call,
                            label: 'Call\nEmergency',
                            color: AppColors.accent,
                            onTap: () {
                              final contact = settings.emergencyContact;
                              AppUtils.makePhoneCall(
                                contact.isNotEmpty ? contact : '112',
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.local_police,
                            label: 'Call\nPolice',
                            color: AppColors.primary,
                            onTap: () => AppUtils.makePhoneCall('100'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.map_outlined,
                            label: 'Open\nMaps',
                            color: AppColors.success,
                            onTap: () {
                              if (location.latitude != null) {
                                AppUtils.openInGoogleMaps(
                                  location.latitude!,
                                  location.longitude!,
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Deactivate button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _deactivateSOS,
                        icon: const Icon(Icons.shield_outlined),
                        label: const Text('Deactivate SOS'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.surface,
                          foregroundColor: AppColors.text,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
