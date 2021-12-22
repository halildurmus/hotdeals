import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../models/store.dart';
import '../services/spring_service.dart';
import '../utils/localization_util.dart';

class StoreItem extends StatefulWidget {
  const StoreItem({
    Key? key,
    required this.onTap,
    required this.store,
  }) : super(key: key);

  final VoidCallback onTap;
  final Store store;

  @override
  _StoreItemState createState() => _StoreItemState();
}

class _StoreItemState extends State<StoreItem> {
  late Future<int?> numberOfDealsFuture;

  @override
  void initState() {
    numberOfDealsFuture = GetIt.I
        .get<SpringService>()
        .getNumberOfDealsByStore(storeId: widget.store.id!);
    super.initState();
  }

  Widget buildStoreLogo() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      color: isDarkMode ? Colors.white : null,
      padding: isDarkMode ? const EdgeInsets.all(3) : EdgeInsets.zero,
      height: 55,
      width: 55,
      child: CachedNetworkImage(
        imageUrl: widget.store.logo,
        imageBuilder: (ctx, imageProvider) => Hero(
          tag: widget.store.id!,
          child: DecoratedBox(
            decoration: BoxDecoration(
              image: DecorationImage(image: imageProvider),
            ),
          ),
        ),
        placeholder: (context, url) => const SizedBox.square(dimension: 50),
      ),
    );
  }

  Widget buildStoreName() {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        widget.store.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: textTheme.headline6!.copyWith(fontSize: 18),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget buildNumberOfDeals() {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    return FutureBuilder<int?>(
      future: numberOfDealsFuture,
      builder: (context, snapshot) {
        var dealsCount = 0;
        if (snapshot.hasData) {
          dealsCount = snapshot.data!;
        }

        return Text(
          l(context).dealCount(dealsCount),
          style: textTheme.subtitle2!.copyWith(
            color: isDarkMode ? theme.primaryColorLight : theme.primaryColor,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.backgroundColor,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: const BorderRadius.all(Radius.circular(24)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildStoreLogo(),
              const SizedBox(height: 8),
              buildStoreName(),
              const SizedBox(height: 8),
              buildNumberOfDeals(),
            ],
          ),
        ),
      ),
    );
  }
}
