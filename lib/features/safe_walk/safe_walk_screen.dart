import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../state/providers.dart';

class SafeWalkScreen extends ConsumerStatefulWidget {
  const SafeWalkScreen({super.key});

  @override
  ConsumerState<SafeWalkScreen> createState() => _SafeWalkScreenState();
}

class _SafeWalkScreenState extends ConsumerState<SafeWalkScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(locationProvider.notifier).startTracking();
    });
  }

  @override
  void dispose() {
    final walk = ref.read(safeWalkProvider);
    if (walk.isActive) {
      ref.read(safeWalkProvider.notifier).stopWalk();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final walk = ref.watch(safeWalkProvider);
    final location = ref.watch(locationProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.arrow_back_ios_new,
                          color: AppColors.text, size: 18),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Safe Walk',
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (walk.isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.success,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            AppUtils.formatDuration(walk.durationSeconds),
                            style: TextStyle(
                              color: AppColors.success,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Drop alert
            if (walk.phoneDropped)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color: AppColors.accent, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Phone drop detected!',
                              style: TextStyle(
                                color: AppColors.accent,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Are you okay?',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => ref
                            .read(safeWalkProvider.notifier)
                            .dismissDropAlert(),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.close,
                              color: AppColors.text, size: 16),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/sos'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'SOS',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 8),

            // Map
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.surfaceLight),
                ),
                clipBehavior: Clip.antiAlias,
                child: location.latitude != null
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
                                width: 50,
                                height: 50,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: walk.isActive
                                        ? AppColors.success.withValues(alpha: 0.3)
                                        : AppColors.primary.withValues(alpha: 0.3),
                                    border: Border.all(
                                      color: walk.isActive
                                          ? AppColors.success
                                          : AppColors.primary,
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    walk.isActive
                                        ? Icons.directions_walk
                                        : Icons.person,
                                    color: walk.isActive
                                        ? AppColors.success
                                        : AppColors.primary,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    : Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primary),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Status & controls
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (!walk.isActive)
                    // Start walk info
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: AppColors.primary, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Safe Walk keeps your screen on, tracks location, and detects if your phone is dropped.',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (walk.isActive) {
                          ref.read(safeWalkProvider.notifier).stopWalk();
                        } else {
                          ref.read(safeWalkProvider.notifier).startWalk();
                        }
                        AppUtils.hapticMedium();
                      },
                      icon: Icon(walk.isActive ? Icons.stop : Icons.directions_walk),
                      label: Text(walk.isActive ? 'Stop Walk' : 'Start Safe Walk'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            walk.isActive ? AppColors.accent : AppColors.success,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
