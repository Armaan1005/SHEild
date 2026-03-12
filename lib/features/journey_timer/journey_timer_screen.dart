import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../state/providers.dart';

class JourneyTimerScreen extends ConsumerStatefulWidget {
  const JourneyTimerScreen({super.key});

  @override
  ConsumerState<JourneyTimerScreen> createState() => _JourneyTimerScreenState();
}

class _JourneyTimerScreenState extends ConsumerState<JourneyTimerScreen> {
  int _selectedMinutes = 15;
  final _destController = TextEditingController(text: 'Home');
  final List<int> _presets = [10, 15, 20, 30, 45, 60];

  @override
  void dispose() {
    _destController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timer = ref.watch(journeyTimerProvider);

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
                  Text(
                    'Journey Timer',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: timer.isActive || timer.hasExpired
                    ? _buildActiveTimer(timer)
                    : _buildSetupTimer(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSetupTimer() {
    return Column(
      children: [
        const SizedBox(height: 20),
        // Info
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Icon(Icons.timer_outlined,
                  color: AppColors.primary, size: 48),
              const SizedBox(height: 12),
              Text(
                'Reach Safe Timer',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Set a timer for your journey. If you don\'t mark "Reached Safe" before it expires, SOS will be triggered.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // Destination
        Align(
          alignment: Alignment.centerLeft,
          child: Text('Destination',
              style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _destController,
          style: TextStyle(color: AppColors.text, fontSize: 14),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.place_outlined,
                color: AppColors.primary, size: 20),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Time selection
        Align(
          alignment: Alignment.centerLeft,
          child: Text('Estimated Time',
              style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _presets.map((min) {
            final selected = _selectedMinutes == min;
            return GestureDetector(
              onTap: () {
                setState(() => _selectedMinutes = min);
                AppUtils.hapticLight();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: selected
                      ? null
                      : Border.all(color: AppColors.surfaceLight),
                ),
                child: Text(
                  '$min min',
                  style: TextStyle(
                    color: selected ? Colors.white : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 32),

        // Start button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              ref.read(journeyTimerProvider.notifier).startTimer(
                    minutes: _selectedMinutes,
                    destination: _destController.text,
                  );
              AppUtils.hapticMedium();
            },
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Start Timer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveTimer(JourneyTimerState timer) {
    final progress = timer.totalSeconds > 0
        ? (timer.totalSeconds - timer.remainingSeconds) / timer.totalSeconds
        : 0.0;

    return Column(
      children: [
        const SizedBox(height: 40),
        // Timer circle
        SizedBox(
          width: 220,
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 220,
                height: 220,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: AppColors.surfaceLight,
                  color: timer.hasExpired
                      ? AppColors.accent
                      : AppColors.primary,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    timer.hasExpired
                        ? '00:00'
                        : AppUtils.formatDuration(timer.remainingSeconds),
                    style: TextStyle(
                      color: timer.hasExpired
                          ? AppColors.accent
                          : AppColors.text,
                      fontSize: 44,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timer.hasExpired ? 'TIME\'S UP!' : 'remaining',
                    style: TextStyle(
                      color: timer.hasExpired
                          ? AppColors.accent
                          : AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: timer.hasExpired
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Destination
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.place, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                timer.destination,
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),

        if (timer.hasExpired) ...[
          // Expired - SOS options
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: AppColors.accent, size: 36),
                const SizedBox(height: 8),
                Text(
                  'You haven\'t marked safe!',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Are you okay?',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ref.read(journeyTimerProvider.notifier).markSafe();
                    AppUtils.hapticLight();
                  },
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('I\'m Safe'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ref.read(journeyTimerProvider.notifier).cancelTimer();
                    Navigator.pushNamed(context, '/sos');
                  },
                  icon: const Icon(Icons.emergency),
                  label: const Text('SOS'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ] else ...[
          // Active - safe button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ref.read(journeyTimerProvider.notifier).markSafe();
                AppUtils.hapticLight();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Glad you\'re safe! 💚'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
              icon: const Icon(Icons.check_circle),
              label: const Text('Reached Safe'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              ref.read(journeyTimerProvider.notifier).cancelTimer();
            },
            child: Text(
              'Cancel Timer',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ],
    );
  }
}
