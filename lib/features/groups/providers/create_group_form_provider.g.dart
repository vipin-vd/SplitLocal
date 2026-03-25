// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_group_form_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CreateGroupForm)
final createGroupFormProvider = CreateGroupFormProvider._();

final class CreateGroupFormProvider
    extends $NotifierProvider<CreateGroupForm, CreateGroupFormState> {
  CreateGroupFormProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'createGroupFormProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$createGroupFormHash();

  @$internal
  @override
  CreateGroupForm create() => CreateGroupForm();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateGroupFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateGroupFormState>(value),
    );
  }
}

String _$createGroupFormHash() => r'ef49a35d8ee4801009533f1df2396851bc517efe';

abstract class _$CreateGroupForm extends $Notifier<CreateGroupFormState> {
  CreateGroupFormState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<CreateGroupFormState, CreateGroupFormState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<CreateGroupFormState, CreateGroupFormState>,
        CreateGroupFormState,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
