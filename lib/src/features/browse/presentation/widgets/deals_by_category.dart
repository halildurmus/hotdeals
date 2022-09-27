import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart'
    show PagingController;

import '../../../../common_widgets/error_indicator.dart';
import '../../../../core/hotdeals_repository.dart';
import '../../../../helpers/context_extensions.dart';
import '../../../deals/domain/deal.dart';
import '../../../deals/presentation/widgets/deal_paged_list_view.dart';
import '../../domain/category.dart';
import 'filter_chips.dart';

class DealsByCategory extends ConsumerStatefulWidget {
  const DealsByCategory({required this.category, super.key});

  final Category category;

  @override
  ConsumerState<DealsByCategory> createState() => _DealsByCategoryState();
}

class _DealsByCategoryState extends ConsumerState<DealsByCategory> {
  late Category category;
  late PagingController<int, Deal> _pagingController;

  @override
  void initState() {
    category = widget.category;
    _pagingController = PagingController<int, Deal>(firstPageKey: 0);
    super.initState();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          centerTitle: true,
          title: Text(category.localizedName(Localizations.localeOf(context))),
        ),
      ),
      body: Column(
        children: [
          FilterChips(
            category: widget.category,
            onFilterChange: (newCategory) {
              setState(() {
                category = newCategory;
                _pagingController.refresh();
              });
            },
          ),
          Expanded(
            child: DealPagedListView(
              dealsFuture: (int page, int size) =>
                  ref.read(hotdealsRepositoryProvider).getDealsByCategory(
                        category: category.category,
                        page: page,
                        size: size,
                      ),
              noDealsFound: ErrorIndicator(
                icon: Icons.local_offer,
                title: context.l.couldNotFindAnyDeal,
              ),
              pagingController: _pagingController,
            ),
          ),
        ],
      ),
    );
  }
}
