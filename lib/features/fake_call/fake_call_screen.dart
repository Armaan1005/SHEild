import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../state/providers.dart';

class FakeCallScreen extends ConsumerStatefulWidget {
  const FakeCallScreen({super.key});

  @override
  ConsumerState<FakeCallScreen> createState() => _FakeCallScreenState();
}

class _FakeCallScreenState extends ConsumerState<FakeCallScreen>
    with TickerProviderStateMixin {
  bool _isRinging = false;
  bool _isConnected = false;
  int _callSeconds = 0;
  Timer? _delayTimer;
  Timer? _callTimer;
  late AnimationController _ringController;
  late Animation<double> _ringAnimation;

  @override
  void initState() {
    super.initState();
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _ringAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _ringController, curve: Curves.elasticIn),
    );

    // Delay before ringing
    _delayTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _isRinging = true);
        _ringController.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _callTimer?.cancel();
    _ringController.dispose();
    super.dispose();
  }

  void _acceptCall() {
    _ringController.stop();
    _ringController.reset();
    setState(() {
      _isRinging = false;
      _isConnected = true;
    });
    _callTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _callSeconds++);
    });
  }

  void _endCall() {
    _callTimer?.cancel();
    Navigator.pop(context);
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final callerName = settings.fakeCallerName.isEmpty
        ? 'Mom'
        : settings.fakeCallerName;

    if (!_isRinging && !_isConnected) {
      // Waiting screen
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: AppColors.primary),
                const SizedBox(height: 24),
                const Text(
                  'Incoming call in 3 seconds...',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 32),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            // Caller avatar
            AnimatedBuilder(
              animation: _ringAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _isRinging ? _ringAnimation.value : 0,
                  child: child,
                );
              },
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 30,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Caller name
            Text(
              callerName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isConnected
                  ? _formatTime(_callSeconds)
                  : 'Incoming Call...',
              style: TextStyle(
                color: _isConnected
                    ? AppColors.success
                    : AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
            const Spacer(flex: 3),

            // Call actions
            if (_isRinging)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Decline
                    _CallActionButton(
                      icon: Icons.call_end,
                      color: AppColors.accent,
                      label: 'Decline',
                      onTap: _endCall,
                    ),
                    // Accept
                    _CallActionButton(
                      icon: Icons.call,
                      color: AppColors.success,
                      label: 'Accept',
                      onTap: _acceptCall,
                    ),
                  ],
                ),
              )
            else if (_isConnected)
              // End call button
              _CallActionButton(
                icon: Icons.call_end,
                color: AppColors.accent,
                label: 'End Call',
                onTap: _endCall,
              ),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}

class _CallActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _CallActionButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 16,
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
