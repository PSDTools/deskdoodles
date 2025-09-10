/// The library provides a mixin to allow bootstrapping a widget into a full-fledged app.
library;

// `riverpod_lint` doesn't recognize that this is the root of the app.
// ignore_for_file: scoped_providers_should_specify_dependencies

import 'dart:developer';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../features/settings/application/settings_service.dart';
import '../features/settings/domain/settings_model.dart';

/// The signature of [runApp].
typedef RunApp = void Function(Widget app);

/// The environment needed to bootstrap the app.
typedef BootstrapEnv = ({RunApp runApp});

/// Turn any widget into a flow-blown app.
mixin Bootstrap implements Widget {
  /// Bootstrap the app given a [BootstrapEnv].
  ///
  /// This involves
  /// - setting [FlutterError.onError] to log errors to the console,
  /// - calling [usePathUrlStrategy] to use path-style URLs,
  /// - setting up the [SettingsService] and loading the user's preferences,
  /// - initializing riverpod's [ProviderScope], and
  /// - running the app with [runApp].
  Future<void> bootstrap(BootstrapEnv env) async {
    final (:runApp) = env;

    // Don't use hash style routes.
    usePathUrlStrategy();

    // Bind Flutter to the native platform.
    WidgetsFlutterBinding.ensureInitialized();

    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top],
    );

    // Run the app.
    runApp(
      ProviderScope(
        overrides: [
          initialSettingsProvider.overrideWithValue(
            const SettingsModel(themeMode: ThemeMode.system),
          ),
        ],
        observers: const [if (kDebugMode) _ProviderInspector()],
        child: RestorationScope(restorationId: 'root', child: this),
      ),
    );
  }
}

base class _ProviderInspector extends ProviderObserver {
  const _ProviderInspector();

  @override
  void didAddProvider(ProviderObserverContext context, Object? value) {
    log('${context.provider} added: ${_normalizedValue(value)}');
  }

  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    log(
      '${context.provider} updated: ${_normalizedValue(previousValue)} -> ${_normalizedValue(newValue)}',
    );
  }

  @override
  void didDisposeProvider(ProviderObserverContext context) {
    log('${context.provider} disposed');
  }
}

String _normalizedValue(Object? value) {
  return switch (value) {
    String _ => value,
    Uint8List _ => 'Uint8List(${value.length})',
    AsyncData<Uint8List>(:final value) =>
      'AsyncData<Uint8List>(value: ${_normalizedValue(value)})',
    final IList<Uint8List> list => '[${list.map(_normalizedValue).join(', ')}]',
    _ => value.toString(),
  };
}
