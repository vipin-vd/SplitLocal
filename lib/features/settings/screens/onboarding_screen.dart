import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splitlocal/features/settings/providers/onboarding_provider.dart';
import '../../groups/screens/groups_screen.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(onboardingProvider.select((s) => s.isSaving), (prev, isSaving) {
      if (!isSaving && prev == true) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const GroupsScreen()));
      }
    });

    return const Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.account_balance_wallet,
                  size: 80, color: Color(0xFF6C63FF)),
              SizedBox(height: 24),
              Text('Welcome to SplitLocal',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
              SizedBox(height: 12),
              Text(
                  'Track and split expenses with your groups, all stored locally on your device.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center),
              SizedBox(height: 48),
              _OnboardingForm(),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingForm extends ConsumerWidget {
  const _OnboardingForm();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    return Form(
      key: state.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Who are you?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          TextFormField(
            controller: state.nameController,
            decoration: const InputDecoration(
                labelText: 'Your Name',
                hintText: 'e.g., John Doe',
                prefixIcon: Icon(Icons.person)),
            textCapitalization: TextCapitalization.words,
            validator: (value) => (value == null || value.trim().isEmpty)
                ? 'Please enter your name'
                : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: state.phoneController,
            decoration: const InputDecoration(
                labelText: 'Phone Number (Optional)',
                hintText: 'e.g., +1234567890',
                prefixIcon: Icon(Icons.phone)),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: state.isSaving ? null : notifier.completeOnboarding,
            style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16)),
            child: state.isSaving
                ? const CircularProgressIndicator()
                : const Text('Get Started', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
