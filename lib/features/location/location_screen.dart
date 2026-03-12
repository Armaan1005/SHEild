import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../state/providers.dart';

class LocationScreen extends ConsumerStatefulWidget {
  const LocationScreen({super.key});

  @override
  ConsumerState<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends ConsumerState<LocationScreen> {
  final MapController _mapController = MapController();
  bool _showDangerZones = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(locationProvider.notifier).startTracking();
    });
  }

  @override
  void dispose() {
    ref.read(locationProvider.notifier).stopTracking();
    super.dispose();
  }

  void _addDangerZone() {
    final loc = ref.read(locationProvider);
    if (loc.latitude == null) return;

    final nameCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Mark Danger Zone',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pin current location as an unsafe area',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameCtrl,
              style: TextStyle(color: AppColors.text, fontSize: 14),
              decoration: InputDecoration(
                labelText: 'Zone Label',
                hintText: 'e.g. Dark alley, Isolated area',
                labelStyle: TextStyle(
                    color: AppColors.textSecondary, fontSize: 13),
                hintStyle: TextStyle(
                    color: AppColors.surfaceLight, fontSize: 13),
                prefixIcon: Icon(Icons.warning_amber,
                    color: AppColors.warning, size: 20),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (nameCtrl.text.isNotEmpty) {
                    ref.read(dangerZonesProvider.notifier).addZone(
                          DangerZone(
                            latitude: loc.latitude!,
                            longitude: loc.longitude!,
                            label: nameCtrl.text,
                          ),
                        );
                    Navigator.pop(ctx);
                    AppUtils.hapticLight();
                  }
                },
                icon: const Icon(Icons.add_location_alt),
                label: const Text('Mark Zone'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final location = ref.watch(locationProvider);
    final dangerZones = ref.watch(dangerZonesProvider);

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
                      'Live Location',
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // Toggle danger zones
                  GestureDetector(
                    onTap: () =>
                        setState(() => _showDangerZones = !_showDangerZones),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _showDangerZones
                            ? AppColors.warning.withValues(alpha: 0.15)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        color: _showDangerZones
                            ? AppColors.warning
                            : AppColors.textSecondary,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _addDangerZone,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.add_location_alt_outlined,
                          color: AppColors.textSecondary, size: 20),
                    ),
                  ),
                ],
              ),
            ),

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
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: LatLng(
                              location.latitude!, location.longitude!),
                          initialZoom: 15,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.sheild.app',
                          ),
                          // Danger zone markers
                          if (_showDangerZones && dangerZones.isNotEmpty)
                            MarkerLayer(
                              markers: dangerZones.map((zone) {
                                return Marker(
                                  point:
                                      LatLng(zone.latitude, zone.longitude),
                                  width: 40,
                                  height: 40,
                                  child: Tooltip(
                                    message: zone.label,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.warning
                                            .withValues(alpha: 0.3),
                                        border: Border.all(
                                            color: AppColors.warning,
                                            width: 2),
                                      ),
                                      child: Icon(Icons.warning,
                                          color: AppColors.warning,
                                          size: 18),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          // User marker
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
                                    color:
                                        AppColors.primary.withValues(alpha: 0.3),
                                    border: Border.all(
                                        color: AppColors.primary, width: 2),
                                  ),
                                  child: Icon(Icons.person,
                                      color: AppColors.primary, size: 22),
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
                            CircularProgressIndicator(
                                color: AppColors.primary),
                            const SizedBox(height: 16),
                            Text(
                              'Getting location...',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),

            // Location info + actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  if (location.latitude != null)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.gps_fixed,
                              color: AppColors.primary, size: 18),
                          const SizedBox(width: 10),
                          Text(
                            '${AppUtils.formatCoordinate(location.latitude!)}, ${AppUtils.formatCoordinate(location.longitude!)}',
                            style: TextStyle(
                              color: AppColors.text,
                              fontSize: 13,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 10),
                  // Danger zones count
                  if (dangerZones.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber,
                              color: AppColors.warning, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            '${dangerZones.length} danger zone${dangerZones.length > 1 ? 's' : ''} marked',
                            style: TextStyle(
                              color: AppColors.warning,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 10),
                  if (location.latitude != null)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => AppUtils.openInGoogleMaps(
                            location.latitude!, location.longitude!),
                        icon: const Icon(Icons.map_outlined, size: 18),
                        label: const Text('Open in Google Maps'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
