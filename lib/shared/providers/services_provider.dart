import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../services/storage/local_storage_service.dart';
import '../../services/debt_calculator_service.dart';
import '../../services/contacts_service.dart';
import '../../services/whatsapp_service.dart';
import '../../services/export_import_service.dart';

part 'services_provider.g.dart';

@riverpod
LocalStorageService localStorageService(Ref ref) {
  return LocalStorageService();
}

@riverpod
DebtCalculatorService debtCalculatorService(Ref ref) {
  return DebtCalculatorService();
}

@riverpod
ContactsService contactsService(Ref ref) {
  return ContactsService();
}

@riverpod
WhatsAppService whatsAppService(Ref ref) {
  final debtCalculator = ref.watch(debtCalculatorServiceProvider);
  return WhatsAppService(debtCalculator);
}

@riverpod
ExportImportService exportImportService(Ref ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return ExportImportService(storage);
}
