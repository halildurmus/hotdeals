import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../helpers/context_extensions.dart';
import '../../../../l10n/localization_constants.dart';
import '../../../search/presentation/search_controller.dart';

class DealsScreenAppBar extends ConsumerWidget {
  const DealsScreenAppBar({required this.tabController, super.key});

  final TabController tabController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final floatingSearchBarController = ref.watch(searchControllerProvider
        .select((value) => value.floatingSearchBarController));
    return AppBar(
      actions: [
        IconButton(
          onPressed: () {
            ref
                .read(searchControllerProvider.notifier)
                .onSearchModeChanged(true);
            WidgetsBinding.instance.addPostFrameCallback(
                (_) => floatingSearchBarController.open());
          },
          icon: const Icon(Icons.search),
        ),
        IconButton(
          onPressed: () => context.go('/post-deal'),
          icon: const Icon(Icons.add_circle),
        ),
      ],
      automaticallyImplyLeading: false,
      title: const Text(appTitle),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 2),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TabBar(
              controller: tabController,
              isScrollable: true,
              labelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              tabs: [
                Tab(text: context.l.latest),
                Tab(text: context.l.mostLiked)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
