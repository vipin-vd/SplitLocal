import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:splitlocal/shared/providers/services_provider.dart';

part 'initialization_provider.g.dart';

@riverpod
Future<bool> initialization(InitializationRef ref) async {
  final storage = ref.read(localStorageServiceProvider);
  // The initialize method is empty, but we keep it for consistency.
  await storage.initialize();
  return storage.isOnboardingComplete;
}
