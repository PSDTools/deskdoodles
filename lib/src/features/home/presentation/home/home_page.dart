import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../app/router.gr.dart';

@RoutePage(deferredLoading: true)
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  static const List<PageRouteInfo<void>> _destinations = [
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
