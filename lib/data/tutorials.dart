class TutorialStep {
  final String title;
  final String description;
  final String? imageAsset;

  const TutorialStep({
    required this.title,
    required this.description,
    this.imageAsset,
  });
}

class Tutorial {
  final String title;
  final String description;
  final String duration;
  final String category;
  final List<String> tools;
  final String warning;
  final List<TutorialStep> steps;

  const Tutorial({
    required this.title,
    required this.description,
    required this.duration,
    required this.category,
    this.tools = const [],
    this.warning = '',
    required this.steps,
  });
}

// images sourced from wikihow.com/Free-Up-Space-on-Your-iPhone (CC BY-NC-SA 3.0)
const Tutorial iosStorageTutorial = Tutorial(
  title: 'Free up Storage Space',
  description: 'Free space on your iPhone by using your iPhone\'s Storage Menu',
  duration: '5min',
  category: 'Storage',
  steps: [
    TutorialStep(
      title: 'Open Settings',
      description: 'To get started, tap the Settings icon on your Home Screen or in your App Library.',
      imageAsset: 'assets/ios/Step-1.jpg',
    ),
    TutorialStep(
      title: 'Tap General',
      description: 'You\'ll find this in the third group of options in the Settings menu.',
      imageAsset: 'assets/ios/Step-2.jpg',
    ),
    TutorialStep(
      title: 'Tap iPhone Storage',
      description: 'This menu shows a breakdown of storage usage by category (Apps, Photos, Messages, etc.).',
      imageAsset: 'assets/ios/Step-3.jpg',
    ),
    TutorialStep(
      title: 'Review Recommendations',
      description: 'Check the Recommendations section at the top for quick wins like Offload Unused Apps or Review Large Attachments.',
      imageAsset: 'assets/ios/step-4.jpg',
    ),
    TutorialStep(
      title: 'Audit App List',
      description: 'Scroll down to see apps sorted by size. Tap any app to offload or delete it and reclaim space instantly.',
      imageAsset: 'assets/ios/step-5.jpg',
    ),
  ],
);

// images sourced from wikihow.com
const Tutorial androidStorageTutorial = Tutorial(
  title: 'Archiving Unused Apps',
  description: 'Free up space and optimise performance on your Android device by archiving unused apps',
  duration: '5min',
  category: 'Storage',
  steps: [
    TutorialStep(
      title: 'Open the Google Play Store',
      description: 'Tap the Play Store icon on your device to get started.',
      imageAsset: 'assets/android/step1.jpg',
    ),
    TutorialStep(
      title: 'Tap Your Profile Icon',
      description: 'Tap your profile icon in the top-right corner of the Play Store.',
      imageAsset: 'assets/android/step2.jpg',
    ),
    TutorialStep(
      title: 'Open Settings',
      description: 'Select Settings from the menu, then tap General.',
      imageAsset: 'assets/android/step3.jpg',
    ),
    TutorialStep(
      title: 'Enable Auto-Archive',
      description: 'Toggle on "Automatically archive apps" to remove app binaries while keeping your data and documents.',
      imageAsset: 'assets/android/step4.jpg',
    ),
    TutorialStep(
      title: 'Confirm Archiving',
      description: 'Your device will now automatically archive unused apps when storage is low, freeing up space without losing data.',
      imageAsset: 'assets/android/step5.jpeg',
    ),
  ],
);

const List<Tutorial> baseTutorials = [
  Tutorial(
    title: 'Storage Performance Reduction',
    description: 'Clear cache, uninstall unused apps, move photos to cloud...',
    duration: '1min',
    category: 'Storage',
    steps: [
      TutorialStep(
        title: 'Open Storage Settings',
        description: 'Go to Settings > Storage to see what is taking up space on your device.',
      ),
      TutorialStep(
        title: 'Clear App Cache',
        description: 'Tap on individual apps and select "Clear Cache" to free up space without deleting data.',
      ),
      TutorialStep(
        title: 'Delete Unused Apps',
        description: 'Remove apps you no longer use. Long-press an app icon and select Uninstall.',
      ),
      TutorialStep(
        title: 'Move Photos to Cloud',
        description: 'Back up your photos to Google Photos or another cloud service, then delete local copies.',
      ),
    ],
  ),
  Tutorial(
    title: 'Replace Battery',
    description: 'Remove screen, disconnect battery cable, replace battery...',
    duration: '45min',
    category: 'Battery',
    tools: ['Small cross screwdriver', 'Replacement battery'],
    warning: 'Repairing your device involves delicate components. Removing your screen or replacing the battery may cause permanent damage if not done correctly. Proceed only if you\'re experienced and follow proper safety steps.',
    steps: [
      TutorialStep(
        title: 'Power Off the Device',
        description: 'Turn off your phone completely to prevent electrical damage or accidental input during the repair.',
      ),
      TutorialStep(
        title: 'Remove the Back Cover',
        description: 'Use a small cross screwdriver to remove the screws on the back cover. Carefully pry off the cover using a plastic spudger.',
      ),
      TutorialStep(
        title: 'Disconnect the Battery Cable',
        description: 'Locate the battery connector and gently disconnect it from the motherboard.',
      ),
      TutorialStep(
        title: 'Remove the Old Battery',
        description: 'Use a plastic spudger to carefully lift the battery. Avoid puncturing it.',
      ),
      TutorialStep(
        title: 'Insert the New Battery',
        description: 'Place the new battery in the same position and reconnect the battery cable.',
      ),
      TutorialStep(
        title: 'Reassemble and Test',
        description: 'Replace the back cover, screw it in, then power on the device to verify the repair.',
      ),
    ],
  ),
  Tutorial(
    title: 'Fix Overheating',
    description: 'Close background apps, check charging habits, update software...',
    duration: '5min',
    category: 'Overheating',
    steps: [
      TutorialStep(
        title: 'Close Background Apps',
        description: 'Open your recent apps and close all unnecessary applications running in the background.',
      ),
      TutorialStep(
        title: 'Check Charging Habits',
        description: 'Avoid using your phone while charging. Use the original charger to prevent overheating.',
      ),
      TutorialStep(
        title: 'Update Your Software',
        description: 'Go to Settings > System > Software Update and install any available updates.',
      ),
      TutorialStep(
        title: 'Reset Network Settings',
        description: 'If overheating persists, go to Settings > General > Reset > Reset Network Settings.',
      ),
      TutorialStep(
        title: 'Monitor Temperature',
        description: 'Use the Techare diagnostics tool to keep monitoring your device temperature.',
      ),
    ],
  ),
  Tutorial(
    title: 'Improve Battery Life',
    description: 'Adjust brightness, disable background refresh, enable battery saver...',
    duration: '2min',
    category: 'Battery',
    steps: [
      TutorialStep(
        title: 'Reduce Screen Brightness',
        description: 'Lower your screen brightness or enable adaptive brightness in Settings > Display.',
      ),
      TutorialStep(
        title: 'Enable Battery Saver',
        description: 'Go to Settings > Battery > Battery Saver and turn it on.',
      ),
      TutorialStep(
        title: 'Disable Background App Refresh',
        description: 'Go to Settings > Apps and restrict background activity for apps you don\'t need running constantly.',
      ),
      TutorialStep(
        title: 'Check Battery Usage',
        description: 'Go to Settings > Battery > Battery Usage to identify which apps are draining your battery most.',
      ),
    ],
  ),
];

List<Tutorial> tutorialsForBrand(String phoneBrand) {
  final storageGuide = phoneBrand.toLowerCase() == 'apple'
      ? iosStorageTutorial
      : androidStorageTutorial;
  return [...baseTutorials, storageGuide];
}
