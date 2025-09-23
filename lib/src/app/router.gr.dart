// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i5;
import 'package:deskdoodles/src/features/friends/presentation/friends_list/friends_list_page.dart'
    deferred as _i1;
import 'package:deskdoodles/src/features/home/presentation/home/home_page.dart'
    deferred as _i2;
import 'package:deskdoodles/src/features/home/presentation/your_room/your_room_page.dart'
    deferred as _i4;
import 'package:deskdoodles/src/features/settings/presentation/preferences/settings_page.dart'
    deferred as _i3;

/// generated route for
/// [_i1.FriendsListPage]
class FriendsListRoute extends _i5.PageRouteInfo<void> {
  const FriendsListRoute({List<_i5.PageRouteInfo>? children})
    : super(
        FriendsListRoute.name,
        initialChildren: children,
        argsEquality: false,
      );

  static const String name = 'FriendsListRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return _i5.DeferredWidget(_i1.loadLibrary, () => _i1.FriendsListPage());
    },
  );
}

/// generated route for
/// [_i2.HomePage]
class HomeRoute extends _i5.PageRouteInfo<void> {
  const HomeRoute({List<_i5.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children, argsEquality: false);

  static const String name = 'HomeRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return _i5.DeferredWidget(_i2.loadLibrary, () => _i2.HomePage());
    },
  );
}

/// generated route for
/// [_i3.SettingsPage]
class SettingsRoute extends _i5.PageRouteInfo<void> {
  const SettingsRoute({List<_i5.PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children, argsEquality: false);

  static const String name = 'SettingsRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return _i5.DeferredWidget(_i3.loadLibrary, () => _i3.SettingsPage());
    },
  );
}

/// generated route for
/// [_i4.YourRoomPage]
class YourRoomRoute extends _i5.PageRouteInfo<void> {
  const YourRoomRoute({List<_i5.PageRouteInfo>? children})
    : super(YourRoomRoute.name, initialChildren: children, argsEquality: false);

  static const String name = 'YourRoomRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return _i5.DeferredWidget(_i4.loadLibrary, () => _i4.YourRoomPage());
    },
  );
}
