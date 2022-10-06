import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../common_widgets/error_indicator.dart';
import '../../../../../core/hotdeals_repository.dart';
import '../../../../../helpers/context_extensions.dart';
import '../../../../deal/presentation/widgets/deal_paged_list_view.dart';

class MyFavoritesTab extends ConsumerWidget {
  const MyFavoritesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DealPagedListView(
      dealsFuture: (page, size) => ref
          .read(hotdealsRepositoryProvider)
          .getUserFavorites(page: page, size: size),
      noDealsFound: ErrorIndicator(
        icon: Icons.favorite_outline,
        title: context.l.noFavoritesYet,
        message: context.l.noFavoritesYetDescription,
      ),
      pageSize: 8,
      removeDealWhenUnfavorited: true,
    );
  }
}
