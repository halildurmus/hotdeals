import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../common_widgets/error_indicator.dart';
import '../../../../../core/hotdeals_repository.dart';
import '../../../../../helpers/context_extensions.dart';
import '../../../../deals/presentation/widgets/deal_paged_list_view.dart';

class MyDealsTab extends ConsumerWidget {
  const MyDealsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DealPagedListView(
      dealsFuture: (page, size) => ref
          .read(hotdealsRepositoryProvider)
          .getUserDeals(page: page, size: size),
      noDealsFound: ErrorIndicator(
        icon: Icons.local_offer,
        title: context.l.noPostsYet,
      ),
      pageSize: 8,
    );
  }
}
