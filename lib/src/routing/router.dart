import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../common_widgets/error_page.dart';
import '../common_widgets/fullscreen_image.dart';
import '../features/auth/domain/my_user.dart';
import '../features/auth/presentation/sign_in_screen.dart';
import '../features/auth/presentation/user_controller.dart';
import '../features/browse/domain/category.dart';
import '../features/browse/domain/store.dart';
import '../features/browse/presentation/deals_by_category_screen.dart';
import '../features/browse/presentation/deals_by_store_screen.dart';
import '../features/chat/presentation/blocked_users_screen.dart';
import '../features/chat/presentation/message_screen.dart';
import '../features/chat/presentation/widgets/chat_image_preview.dart';
import '../features/deals/domain/deal.dart';
import '../features/deals/presentation/deal_details/deal_details_screen.dart';
import '../features/deals/presentation/deal_details/widgets/images_fullscreen.dart';
import '../features/deals/presentation/post_deal_screen.dart';
import '../features/deals/presentation/update_deal_screen.dart';
import '../features/home/home_screen.dart';
import '../features/profile/presentation/update_profile/update_profile_screen.dart';
import '../features/settings/presentation/settings_screen.dart';

/// Caches and Exposes a [GoRouter].
final routerProvider = Provider<GoRouter>(
  (ref) {
    final router = RouterNotifier(ref);
    return GoRouter(
      errorPageBuilder: (_, state) =>
          MaterialPage(child: ErrorPage(state.error)),
      debugLogDiagnostics: kDebugMode,
      initialLocation: '/',
      redirect: router._redirectLogic,
      refreshListenable: router,
      routes: router._routes,
    );
  },
  name: 'RouterProvider',
);

class RouterNotifier extends ChangeNotifier {
  /// Uses `ref.listen()` to add a simple callback that calls `notifyListeners()`
  /// whenever there's change onto a desider provider.
  RouterNotifier(this._ref) {
    _ref.listen<MyUser?>(
      userProvider,
      (prev, next) {
        if (prev == next) return;
        notifyListeners();
      },
    );
  }

  final Ref _ref;

  String? _redirectLogic(BuildContext context, GoRouterState state) {
    final user = _ref.read(userProvider);
    final loggingIn = state.subloc == '/login';
    // if the user is not logged in, they need to login
    if (user == null) return loggingIn ? null : '/login';

    // if the user is logged in but still on the login page, send them to
    // the home page
    if (loggingIn) return '/';

    // no need to redirect at all
    return null;
  }

  List<GoRoute> get _routes => [
        GoRoute(
          name: 'home',
          path: '/',
          builder: (context, state) => const HomeScreen(),
          routes: [
            GoRoute(
              name: 'blocked-users',
              path: 'blocked-users',
              builder: (context, state) => const BlockedUsersScreen(),
            ),
            GoRoute(
              path: 'chats/:id',
              builder: (context, state) {
                final docId = state.params['id']!;
                final user2 = state.extra! as MyUser;
                return MessageScreen(docId: docId, user2: user2);
              },
              routes: [
                GoRoute(
                  path: 'images/:imageId',
                  builder: (context, state) {
                    final fileName = state.queryParams['name']!;
                    final imageUri = state.queryParams['uri']!
                        .replaceFirst('o/uploads/', 'o/uploads%2F');
                    return ChatImagePreview(
                      fileName: fileName,
                      imageUri: imageUri,
                    );
                  },
                ),
              ],
            ),
            GoRoute(
              path: 'deals',
              builder: (context, state) => const HomeScreen(),
              routes: [
                GoRoute(
                  name: 'byCategory',
                  path: 'byCategory',
                  builder: (context, state) {
                    final category = state.extra! as Category;
                    return DealsByCategoryScreen(category);
                  },
                ),
                GoRoute(
                  name: 'byStore',
                  path: 'byStore',
                  builder: (context, state) {
                    final store = state.extra! as Store;
                    return DealsByStoreScreen(store);
                  },
                ),
                GoRoute(
                  path: ':id',
                  builder: (context, state) {
                    final dealId = state.params['id']!;
                    return DealDetailsScreen(dealId: dealId);
                  },
                  routes: [
                    GoRoute(
                      path: 'images',
                      builder: (context, state) {
                        final currentIndex =
                            int.parse(state.queryParams['index']!);
                        final images = state.extra! as List<String>;
                        return DealImagesFullScreen(
                          imageUrls: images,
                          currentIndex: currentIndex,
                        );
                      },
                    ),
                    GoRoute(
                      name: 'store-image',
                      path: 'store-image',
                      builder: (context, state) {
                        final imageUrl = state.queryParams['url']!;
                        return FullScreenImage(imageUrl: imageUrl);
                      },
                    ),
                  ],
                ),
              ],
            ),
            GoRoute(
              name: 'image',
              path: 'image',
              builder: (context, state) {
                final imageUrl = state.queryParams['url']!;
                return FullScreenImage(imageUrl: imageUrl);
              },
            ),
            GoRoute(
              name: 'post-deal',
              path: 'post-deal',
              builder: (context, state) => const PostDealScreen(),
            ),
            GoRoute(
              name: 'settings',
              path: 'settings',
              builder: (context, state) => const SettingsScreen(),
            ),
            GoRoute(
              name: 'update-deal',
              path: 'update-deal',
              builder: (context, state) {
                final deal = state.extra! as Deal;
                return UpdateDealScreen(deal: deal);
              },
            ),
            GoRoute(
              name: 'update-profile',
              path: 'update-profile',
              builder: (context, state) => const UpdateProfileScreen(),
            ),
          ],
        ),
        GoRoute(
          name: 'login',
          path: '/login',
          builder: (context, state) => const SignInScreen(),
        ),
      ];
}
