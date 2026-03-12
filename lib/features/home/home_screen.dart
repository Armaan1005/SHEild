import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../state/providers.dart';
import '../../widgets/sos_button.dart';
import '../../widgets/action_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = ref.read(settingsProvider);
      if (settings.shakeEnabled) {
        final detector = ref.read(shakeDetectorProvider);
        detector.startListening(() {
          if (mounted) {
            Navigator.pushNamed(context, '/sos');
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    ref.read(shakeDetectorProvider).stopListening();
    super.dispose();
  }

  void _handlePanicTap() {
    final triggered = ref.read(panicPatternProvider.notifier).registerTap();
    if (triggered && mounted) {
      Navigator.pushNamed(context, '/sos');
    }
  }

  @override
  Widget build(BuildContext context) {
    final journeyTimer = ref.watch(journeyTimerProvider);
    final battery = ref.watch(batteryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildTopBar(),
                const SizedBox(height: 16),

                // Battery warning
                if (battery.isLow)
                  _buildBatteryWarning(),

                // Journey timer active banner
                if (journeyTimer.isActive || journeyTimer.hasExpired)
                  _buildJourneyBanner(journeyTimer),

                const SizedBox(height: 8),
                _buildSafetyStatus(),
                const SizedBox(height: 28),

                // SOS Button - also panic tap target
                Center(
                  child: GestureDetector(
                    onDoubleTap: _handlePanicTap,
                    child: SOSButton(
                      onPressed: () {
                        AppUtils.hapticHeavy();
                        Navigator.pushNamed(context, '/sos');
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Tap for SOS  •  5x double-tap for panic alert',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Quick Actions
                Text(
                  'Quick Actions',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 14),
                _buildQuickActions(),
                const SizedBox(height: 20),
                _buildSecondaryActions(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppUtils.getGreeting(),
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Stay Safe ❤️',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        Row(
          children: [
            _buildIconButton(
              Icons.calculate_outlined,
              onTap: () => Navigator.pushNamed(context, '/stealth'),
            ),
            const SizedBox(width: 8),
            _buildIconButton(
              Icons.settings_outlined,
              onTap: () => Navigator.pushNamed(context, '/settings'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIconButton(IconData icon, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: () {
        AppUtils.hapticLight();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.surfaceLight.withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
        child: Icon(icon, color: AppColors.textSecondary, size: 22),
      ),
    );
  }

  Widget _buildBatteryWarning() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: AppColors.warning.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.battery_alert,
                color: AppColors.warning, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Low battery! Location will be sent to contacts.',
                style: TextStyle(
                  color: AppColors.warning,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJourneyBanner(JourneyTimerState timer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/journey-timer'),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: timer.hasExpired
                ? AppColors.accent.withValues(alpha: 0.12)
                : AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: timer.hasExpired
                  ? AppColors.accent.withValues(alpha: 0.3)
                  : AppColors.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                timer.hasExpired ? Icons.warning_amber : Icons.timer,
                color: timer.hasExpired ? AppColors.accent : AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  timer.hasExpired
                      ? 'Journey timer expired! Tap to check in.'
                      : '${timer.destination} — ${AppUtils.formatDuration(timer.remainingSeconds)}',
                  style: TextStyle(
                    color:
                        timer.hasExpired ? AppColors.accent : AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(Icons.chevron_right,
                  color: AppColors.textSecondary, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSafetyStatus() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.verified_user,
              color: AppColors.success,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Safety Active',
                  style: TextStyle(
                    color: AppColors.success,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Shake detection & SOS ready',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.success,
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withValues(alpha: 0.5),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 0.85,
      children: [
        ActionCard(
          icon: Icons.location_on_outlined,
          label: 'Live\nLocation',
          color: AppColors.primaryLight,
          onTap: () => Navigator.pushNamed(context, '/location'),
        ),
        ActionCard(
          icon: Icons.phone_outlined,
          label: 'Fake\nCall',
          color: const Color(0xFFF97316),
          onTap: () => Navigator.pushNamed(context, '/fake-call'),
        ),
        ActionCard(
          icon: Icons.people_outline,
          label: 'Trusted\nContacts',
          color: const Color(0xFF38BDF8),
          onTap: () => Navigator.pushNamed(context, '/trusted-contacts'),
        ),
        ActionCard(
          icon: Icons.timer_outlined,
          label: 'Journey\nTimer',
          color: AppColors.warning,
          onTap: () => Navigator.pushNamed(context, '/journey-timer'),
        ),
        ActionCard(
          icon: Icons.directions_walk,
          label: 'Safe\nWalk',
          color: AppColors.success,
          onTap: () => Navigator.pushNamed(context, '/safe-walk'),
        ),
        ActionCard(
          icon: Icons.folder_outlined,
          label: 'Evidence\nRecorder',
          color: const Color(0xFFA78BFA),
          onTap: () => Navigator.pushNamed(context, '/recorder'),
        ),
      ],
    );
  }

  Widget _buildSecondaryActions() {
    return Column(
      children: [
        // Emergency SMS + Call row
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  AppUtils.hapticMedium();
                  final contacts = ref.read(trustedContactsProvider);
                  final numbers = contacts.map((c) => c.phone).toList();
                  if (numbers.isEmpty) {
                    final settings = ref.read(settingsProvider);
                    if (settings.emergencyContact.isNotEmpty) {
                      numbers.add(settings.emergencyContact);
                    }
                  }
                  if (numbers.isNotEmpty) {
                    AppUtils.sendEmergencySMS(
                      numbers: numbers,
                      message: AppUtils.buildEmergencyMessage(),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.sms_outlined,
                          color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Emergency SMS',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  AppUtils.hapticMedium();
                  final settings = ref.read(settingsProvider);
                  if (settings.emergencyContact.isNotEmpty) {
                    AppUtils.makePhoneCall(settings.emergencyContact);
                  } else {
                    AppUtils.makePhoneCall('112');
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.surfaceLight),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.call,
                          color: AppColors.textSecondary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Emergency Call',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Safety tips + helpline row
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/safety-tips'),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.tips_and_updates_outlined,
                          color: AppColors.warning, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Safety Tips',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => AppUtils.makePhoneCall('1091'),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.support_agent,
                          color: AppColors.textSecondary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Helpline',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
