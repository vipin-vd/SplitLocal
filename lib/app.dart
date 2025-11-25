import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'shared/theme/app_theme.dart';
import 'shared/providers/services_provider.dart';
import 'features/settings/screens/onboarding_screen.dart';
import 'features/groups/screens/groups_screen.dart';

class SplitLocalApp extends ConsumerStatefulWidget {
  const SplitLocalApp({super.key});

  @override
  ConsumerState<SplitLocalApp> createState() => _SplitLocalAppState();
}

class _SplitLocalAppState extends ConsumerState<SplitLocalApp> {
  bool _isInitialized = false;
  bool _isOnboardingComplete = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final storage = ref.read(localStorageServiceProvider);
    
    // Initialize Hive
    await storage.initialize();
    
    // Check onboarding status
    final onboardingComplete = storage.isOnboardingComplete;

    setState(() {
      _isOnboardingComplete = onboardingComplete;
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SplitLocal',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: _isInitialized
          ? (_isOnboardingComplete
              ? const GroupsScreen()
              : const OnboardingScreen())
          : const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
    );
  }
}
