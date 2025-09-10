// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint

part of 'settings_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A class that many Widgets can interact with to read user settings, update user settings, or listen to user settings changes.
///
/// Services are the part of the application layer that glues repositories from the data layer to Flutter [Widget]s in the presentation layer.
/// The SettingsService uses the PreferencesRepository to store and retrieve user settings.

@ProviderFor(SettingsService)
const settingsServiceProvider = SettingsServiceProvider._();

/// A class that many Widgets can interact with to read user settings, update user settings, or listen to user settings changes.
///
/// Services are the part of the application layer that glues repositories from the data layer to Flutter [Widget]s in the presentation layer.
/// The SettingsService uses the PreferencesRepository to store and retrieve user settings.
final class SettingsServiceProvider
    extends $NotifierProvider<SettingsService, SettingsModel> {
  /// A class that many Widgets can interact with to read user settings, update user settings, or listen to user settings changes.
  ///
  /// Services are the part of the application layer that glues repositories from the data layer to Flutter [Widget]s in the presentation layer.
  /// The SettingsService uses the PreferencesRepository to store and retrieve user settings.
  const SettingsServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsServiceHash();

  @$internal
  @override
  SettingsService create() => SettingsService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingsModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingsModel>(value),
    );
  }
}

String _$settingsServiceHash() => r'1aec660edc5b2d622721fccafa37078686d21053';

/// A class that many Widgets can interact with to read user settings, update user settings, or listen to user settings changes.
///
/// Services are the part of the application layer that glues repositories from the data layer to Flutter [Widget]s in the presentation layer.
/// The SettingsService uses the PreferencesRepository to store and retrieve user settings.

abstract class _$SettingsService extends $Notifier<SettingsModel> {
  SettingsModel build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<SettingsModel, SettingsModel>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SettingsModel, SettingsModel>,
              SettingsModel,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Load the user's settings from a local database on startup.

@ProviderFor(initialSettings)
const initialSettingsProvider = InitialSettingsProvider._();

/// Load the user's settings from a local database on startup.

final class InitialSettingsProvider
    extends $FunctionalProvider<SettingsModel, SettingsModel, SettingsModel>
    with $Provider<SettingsModel> {
  /// Load the user's settings from a local database on startup.
  const InitialSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'initialSettingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$initialSettingsHash();

  @$internal
  @override
  $ProviderElement<SettingsModel> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SettingsModel create(Ref ref) {
    return initialSettings(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingsModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingsModel>(value),
    );
  }
}

String _$initialSettingsHash() => r'a0f0390bca1cd5ab6176c9db0277de82b1047ff9';
