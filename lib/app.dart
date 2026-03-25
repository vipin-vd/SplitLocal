import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splitlocal/features/home/screens/home_screen.dart';
import 'package:splitlocal/shared/providers/initialization_provider.dart';
import 'package:splitlocal/features/settings/providers/theme_provider.dart';
import 'shared/theme/app_theme.dart';
import 'features/settings/screens/onboarding_screen.dart';

class SplitLocalApp extends ConsumerWidget {
  const SplitLocalApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initialization = ref.watch(initializationProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'SplitLocal',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      home: initialization.when(
        data: (isOnboardingComplete) {
          return isOnboardingComplete
              ? const HomeScreen()
              : const OnboardingScreen();
        },
        loading: () => const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
        error: (err, stack) => Scaffold(
          body: Center(
            child: Text('Error: $err'),
          ),
        ),
      ),
    );
  }
}
