import 'package:auto_route/auto_route.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

const _friends = [
  'Eli',
  'Logan',
  'Parker',
  'Nick',
];

@RoutePage(deferredLoading: true)
class FriendsListPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      itemBuilder: (context, index) {
        final friend = _friends.getOrNull(index);

        if (friend == null) return null;

        return Card(
          child: ListTile(
            leading: const Icon(Icons.person),
            title: Text(
              friend,
              style: const TextStyle(fontFamily: 'Comic Sans MS'),
            ),
          ),
        );
      },
    );
  }
}
