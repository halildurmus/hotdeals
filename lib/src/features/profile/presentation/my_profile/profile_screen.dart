import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../helpers/context_extensions.dart';
import '../../../auth/presentation/user_controller.dart';
import 'widgets/my_deals_tab.dart';
import 'widgets/my_favorites_tab.dart';
import 'widgets/my_profile_tabbar.dart';
import 'widgets/profile_details.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    if (user == null) return const SizedBox();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l.profile),
        actions: [
          IconButton(
            onPressed: () => context.goNamed('settings'),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          headerSliverBuilder: (context, value) => [
            SliverToBoxAdapter(child: ProfileDetails(user: user)),
            const SliverToBoxAdapter(child: MyProfileTabBar()),
          ],
          body: const TabBarView(
            children: [
              MyDealsTab(),
              MyFavoritesTab(),
            ],
          ),
        ),
      ),
    );
  }
}
