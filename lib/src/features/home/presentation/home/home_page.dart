import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../app/router.gr.dart';

/// {@template deskdoodles.features.home.presentation.home.home_page}
/// Create a scaffold to switch between the main sections of the app.
/// {@endtemplate}
@RoutePage(deferredLoading: true)
class HomePage extends ConsumerWidget {
  /// {@macro deskdoodles.features.home.presentation.home.home_page}
  ///
  /// Construct a new [HomePage] widget.
  const HomePage({super.key});

  static const List<PageRouteInfo<void>> _destinations = [
    YourRoomRoute(),
    FriendsListRoute(),
    SettingsRoute(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AutoTabsRouter(
      routes: _destinations,
      builder: (context, child) => Scaffold(
        body: child,
        bottomNavigationBar: _BottomNav(),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: context.tabsRouter.activeIndex,
      onTap: context.tabsRouter.setActiveIndex,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Your Room',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Friends',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}
