import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/hotdeals_repository.dart';
import '../../../../helpers/context_extensions.dart';
import '../../domain/store.dart';

final _numberOfDealsInStoreFutureProvider =
    FutureProvider.autoDispose.family<int?, String>((ref, storeId) async {
  final hotdealsRepository = ref.watch(hotdealsRepositoryProvider);
  return await hotdealsRepository.getNumberOfDealsByStoreId(storeId: storeId);
}, name: 'NumberOfDealsInStoreFutureProvider');

class StoreItem extends ConsumerWidget {
  const StoreItem({required this.store, super.key});

  final Store store;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dealsCount =
        ref.watch(_numberOfDealsInStoreFutureProvider(store.id!));
    return GestureDetector(
      onTap: () => context.go('/deals/byStore', extra: store),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          direction: Axis.vertical,
          runAlignment: WrapAlignment.center,
          spacing: 8,
          children: [
            CachedNetworkImage(
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
              placeholder: (_, __) => const SizedBox.square(dimension: 50),
            ),
            Text(
              store.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.headline6!.copyWith(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            Text(
              context.l.dealCount(dealsCount.value ?? 0),
              style: context.textTheme.subtitle2!.copyWith(
                color: context.isDarkMode
                    ? context.t.primaryColorLight
                    : context.t.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
