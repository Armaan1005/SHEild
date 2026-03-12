import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../core/utils.dart';

class SafetyTipsScreen extends StatelessWidget {
  const SafetyTipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                      child: const Icon(Icons.arrow_back_ios_new,
                          color: AppColors.text, size: 18),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Safety Tips',
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
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Emergency Numbers section
                    _SectionHeader(
                      icon: Icons.call,
                      title: 'Emergency Helplines',
                      color: AppColors.accent,
                    ),
                    const SizedBox(height: 12),
                    _EmergencyNumberCard(
                      label: 'Emergency Number',
                      number: AppConstants.emergencyNumber,
                      icon: Icons.emergency,
                      color: AppColors.accent,
                    ),
                    _EmergencyNumberCard(
                      label: 'Police',
                      number: AppConstants.policeNumber,
                      icon: Icons.local_police,
                      color: AppColors.primary,
                    ),
                    _EmergencyNumberCard(
                      label: 'Women Helpline',
                      number: AppConstants.womenHelpline,
                      icon: Icons.support_agent,
                      color: const Color(0xFFEC4899),
                    ),
                    _EmergencyNumberCard(
                      label: 'Ambulance',
                      number: AppConstants.ambulance,
                      icon: Icons.local_hospital,
                      color: AppColors.success,
                    ),
                    _EmergencyNumberCard(
                      label: 'Child Helpline',
                      number: AppConstants.childHelpline,
                      icon: Icons.child_care,
                      color: AppColors.warning,
                    ),
                    const SizedBox(height: 28),

                    // Safety Guidelines
                    _SectionHeader(
                      icon: Icons.shield,
                      title: 'Safety Guidelines',
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 12),
                    ...AppConstants.safetyTips.asMap().entries.map(
                      (entry) => _TipCard(
                        index: entry.key + 1,
                        title: entry.value['title']!,
                        description: entry.value['description']!,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Self Defense Tips
                    _SectionHeader(
                      icon: Icons.sports_martial_arts,
                      title: 'Self Defense Tips',
                      color: AppColors.warning,
                    ),
                    const SizedBox(height: 12),
                    ...AppConstants.selfDefenseTips.asMap().entries.map(
                      (entry) => _TipCard(
                        index: entry.key + 1,
                        title: entry.value['title']!,
                        description: entry.value['description']!,
                        color: AppColors.warning,
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

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _EmergencyNumberCard extends StatelessWidget {
  final String label;
  final String number;
  final IconData icon;
  final Color color;

  const _EmergencyNumberCard({
    required this.label,
    required this.number,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          label,
          style: const TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          number,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        trailing: GestureDetector(
          onTap: () => AppUtils.makePhoneCall(number),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.call, color: color, size: 20),
          ),
        ),
      ),
    );
  }
}

class _TipCard extends StatefulWidget {
  final int index;
  final String title;
  final String description;
  final Color color;

  const _TipCard({
    required this.index,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  State<_TipCard> createState() => _TipCardState();
}

class _TipCardState extends State<_TipCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: _expanded
              ? Border.all(
                  color: widget.color.withValues(alpha: 0.3),
                )
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${widget.index}',
                    style: TextStyle(
                      color: widget.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.textSecondary,
                  size: 22,
                ),
              ],
            ),
            if (_expanded) ...[
              const SizedBox(height: 12),
              Text(
                widget.description,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
