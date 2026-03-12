import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../state/providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _pinController = TextEditingController();
  final _callerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = ref.read(settingsProvider);
      _nameController.text = settings.emergencyName;
      _numberController.text = settings.emergencyContact;
      _pinController.text = settings.stealthPin;
      _callerController.text = settings.fakeCallerName;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _pinController.dispose();
    _callerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    'Settings',
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
                    // Emergency Contact
                    _SectionTitle(title: 'Emergency Contact'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _SettingsField(
                            controller: _nameController,
                            label: 'Contact Name',
                            icon: Icons.person_outline,
                            hint: 'e.g. Mom, Dad, Friend',
                          ),
                          const SizedBox(height: 16),
                          _SettingsField(
                            controller: _numberController,
                            label: 'Phone Number',
                            icon: Icons.phone_outlined,
                            hint: '+91 XXXXX XXXXX',
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                ref
                                    .read(settingsProvider.notifier)
                                    .updateEmergencyContact(
                                      _nameController.text,
                                      _numberController.text,
                                    );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Contact saved!'),
                                    backgroundColor: AppColors.success,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Save Contact'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Stealth Mode
                    _SectionTitle(title: 'Stealth Mode'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _SettingsField(
                            controller: _pinController,
                            label: 'Secret PIN',
                            icon: Icons.lock_outline,
                            hint: 'e.g. 1234',
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                ref
                                    .read(settingsProvider.notifier)
                                    .updateStealthPin(_pinController.text);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('PIN updated!'),
                                    backgroundColor: AppColors.success,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Update PIN'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Fake Call
                    _SectionTitle(title: 'Fake Call'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _SettingsField(
                            controller: _callerController,
                            label: 'Caller Name',
                            icon: Icons.person_outline,
                            hint: 'e.g. Mom, Office, Friend',
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                ref
                                    .read(settingsProvider.notifier)
                                    .updateFakeCallerName(
                                        _callerController.text);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        const Text('Caller name updated!'),
                                    backgroundColor: AppColors.success,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Update Name'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Feature Toggles
                    _SectionTitle(title: 'Features'),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          SwitchListTile(
                            value: settings.shakeEnabled,
                            onChanged: (v) =>
                                ref.read(settingsProvider.notifier).toggleShake(v),
                            title: const Text(
                              'Shake to SOS',
                              style: TextStyle(
                                  color: AppColors.text, fontSize: 14),
                            ),
                            subtitle: const Text(
                              'Shake phone to trigger SOS',
                              style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12),
                            ),
                            activeTrackColor: AppColors.primary,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 4),
                          ),
                          Divider(
                            height: 1,
                            color: AppColors.surfaceLight.withValues(alpha: 0.5),
                          ),
                          SwitchListTile(
                            value: settings.voiceTriggerEnabled,
                            onChanged: (v) => ref
                                .read(settingsProvider.notifier)
                                .toggleVoiceTrigger(v),
                            title: const Text(
                              'Voice Trigger',
                              style: TextStyle(
                                  color: AppColors.text, fontSize: 14),
                            ),
                            subtitle: const Text(
                              'Say "help me" to trigger SOS',
                              style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12),
                            ),
                            activeTrackColor: AppColors.primary,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // App info
                    Center(
                      child: Column(
                        children: [
                          const Text(
                            'SHEild v1.0.0',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Personal Safety Companion',
                            style: TextStyle(
                              color: AppColors.surfaceLight,
                              fontSize: 12,
                            ),
                          ),
                        ],
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

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
      ),
    );
  }
}

class _SettingsField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String hint;
  final TextInputType? keyboardType;

  const _SettingsField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.hint,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.text, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle:
            const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        hintStyle: TextStyle(
          color: AppColors.surfaceLight,
          fontSize: 13,
        ),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.primary, width: 1),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
