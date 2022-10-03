import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common_widgets/error_indicator.dart';
import '../../../core/hotdeals_repository.dart';
import '../../../helpers/context_extensions.dart';
import '../../deals/presentation/widgets/deal_paged_list_view.dart';
import '../domain/store.dart';
import 'widgets/store_item.dart';

class DealsByStoreScreen extends ConsumerWidget {
  const DealsByStoreScreen(this.store, {super.key});

  final Store store;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          centerTitle: true,
          title: CachedNetworkImage(
            height: 50,
            width: 50,
            imageUrl: store.logo,
            imageBuilder: (_, imageProvider) => DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: context.isDarkMode ? Colors.white : null,
                image: DecorationImage(image: imageProvider),
              ),
            ),
            errorWidget: (_, __, ___) => const StoreImageShimmer(),
            placeholder: (_, __) => const StoreImageShimmer(),
          ),
        ),
      ),
      body: DealPagedListView(
        dealsFuture: (page, size) =>
            ref.read(hotdealsRepositoryProvider).getDealsByStoreId(
                  storeId: store.id!,
                  page: page,
                  size: size,
                ),
        noDealsFound: ErrorIndicator(
          icon: Icons.local_offer,
          title: context.l.couldNotFindAnyDeal,
        ),
        usePushInNavigation: true,
      ),
    );
  }
}
