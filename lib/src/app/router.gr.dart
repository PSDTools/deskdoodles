// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i4;
import 'package:deskdoodles/src/features/friends/presentation/friends_list/friends_list_page.dart'
    deferred as _i1;
import 'package:deskdoodles/src/features/home/presentation/home/home_page.dart'
    deferred as _i2;
import 'package:deskdoodles/src/features/settings/presentation/preferences/settings_page.dart'
    deferred as _i3;

/// generated route for
/// [_i1.FriendsListPage]
class FriendsListRoute extends _i4.PageRouteInfo<void> {
  const FriendsListRoute({List<_i4.PageRouteInfo>? children})
    : super(
        FriendsListRoute.name,
        initialChildren: children,
        argsEquality: false,
      );

  static const String name = 'FriendsListRoute';

  static _i4.PageInfo page = _i4.PageInfo(
    name,
    builder: (data) {
      return _i4.DeferredWidget(_i1.loadLibrary, () => _i1.FriendsListPage());
    },
  );
}

/// generated route for
/// [_i2.HomePage]
class HomeRoute extends _i4.PageRouteInfo<void> {
  const HomeRoute({List<_i4.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children, argsEquality: false);

  static const String name = 'HomeRoute';

  static _i4.PageInfo page = _i4.PageInfo(
    name,
    builder: (data) {
      return _i4.DeferredWidget(_i2.loadLibrary, () => _i2.HomePage());
    },
  );
}

/// generated route for
/// [_i3.SettingsPage]
class SettingsRoute extends _i4.PageRouteInfo<void> {
  const SettingsRoute({List<_i4.PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children, argsEquality: false);

  static const String name = 'SettingsRoute';

  static _i4.PageInfo page = _i4.PageInfo(
    name,
    builder: (data) {
      return _i4.DeferredWidget(_i3.loadLibrary, () => _i3.SettingsPage());
    },
  );
}
