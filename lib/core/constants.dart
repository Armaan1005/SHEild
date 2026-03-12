class AppConstants {
  // App Info
  static const String appName = 'SHEild';
  static const String appTagline = 'Personal Safety Companion';

  // Default Settings
  static const String defaultPin = '1234';
  static const String defaultCallerName = 'Mom';
  static const String defaultCallerNumber = '+91 98765 43210';

  // Emergency Numbers
  static const String policeNumber = '100';
  static const String womenHelpline = '1091';
  static const String ambulance = '102';
  static const String childHelpline = '1098';
  static const String emergencyNumber = '112';

  // Shared Preferences Keys
  static const String keyOnboardingDone = 'onboarding_done';
  static const String keyEmergencyContact = 'emergency_contact';
  static const String keyEmergencyName = 'emergency_name';
  static const String keyStealthPin = 'stealth_pin';
  static const String keyFakeCallerName = 'fake_caller_name';
  static const String keyShakeEnabled = 'shake_enabled';
  static const String keyVoiceTriggerEnabled = 'voice_trigger_enabled';

  // Shake Detection
  static const double shakeThreshold = 15.0;
  static const int shakeCooldownMs = 3000;

  // Safety Tips
  static const List<Map<String, String>> safetyTips = [
    {
      'title': 'Stay Aware of Your Surroundings',
      'description':
          'Always be aware of who is around you. Avoid using your phone while walking alone, especially at night. Keep your head up and look confident.',
    },
    {
      'title': 'Share Your Location',
      'description':
          'Always let someone know where you are going and when you expect to arrive. Use location sharing apps with trusted contacts.',
    },
    {
      'title': 'Trust Your Instincts',
      'description':
          'If something feels wrong, it probably is. Don\'t ignore your gut feeling. Move to a safe, well-lit area with other people.',
    },
    {
      'title': 'Keep Emergency Numbers Ready',
      'description':
          'Save emergency numbers on speed dial. Remember: Police (100), Women Helpline (1091), Ambulance (102), Emergency (112).',
    },
    {
      'title': 'Learn Basic Self-Defense',
      'description':
          'Know basic self-defense moves. Target vulnerable areas: eyes, nose, throat, groin, and knees. Use your elbows and knees as weapons.',
    },
    {
      'title': 'Carry Safety Tools',
      'description':
          'Carry a pepper spray, personal alarm, or a safety whistle. Keep them easily accessible, not buried in your bag.',
    },
    {
      'title': 'Use Well-Lit Routes',
      'description':
          'Stick to well-lit, populated streets. Avoid shortcuts through alleys, parks, or deserted areas, especially at night.',
    },
    {
      'title': 'Secure Your Home',
      'description':
          'Always lock doors and windows. Don\'t open the door to strangers. Use a peephole or camera to verify visitors.',
    },
  ];

  // Self Defense Tips
  static const List<Map<String, String>> selfDefenseTips = [
    {
      'title': 'Palm Strike',
      'description':
          'Use the heel of your palm to strike the attacker\'s nose. This can cause significant pain and disorientation.',
    },
    {
      'title': 'Elbow Strike',
      'description':
          'If the attacker is close, use your elbow. It is one of the most powerful striking tools. Aim for the face, chin, or temple.',
    },
    {
      'title': 'Knee Strike',
      'description':
          'Grab the attacker by the shoulders and drive your knee upward into their groin or solar plexus.',
    },
    {
      'title': 'Escape from Wrist Grab',
      'description':
          'Rotate your arm toward the attacker\'s thumb (the weakest point of their grip) and pull sharply.',
    },
    {
      'title': 'Scream and Run',
      'description':
          'Making noise attracts attention and can scare off attackers. Yell "FIRE!" as people respond faster to fire alarms.',
    },
  ];
}
