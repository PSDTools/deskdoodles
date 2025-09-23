/// This library handles routing for the application declaratively.
library;

import 'package:auto_route/auto_route.dart';

import 'router.gr.dart';

/// The router for the application.
@AutoRouterConfig(
  replaceInRouteName: 'Page,Route',
  deferredLoading: true,
  argsEquality: false,
)
class AppRouter extends RootStackRouter {
  /// Instantiate a new instance of [AppRouter].
  AppRouter();

  @override
  final defaultRouteType = const RouteType.material();

  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      page: HomeRoute.page,
      path: '/',

      children: [
        AutoRoute(page: YourRoomRoute.page, path: '', initial: true),
        AutoRoute(
          page: FriendsListRoute.page,
          path: 'friends',
        ),
        AutoRoute(
          page: SettingsRoute.page,
          path: 'settings',
        ),
      ],
    ),
  ];

  @override
  List<AutoRouteGuard> get guards => [];
}
