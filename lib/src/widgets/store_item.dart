import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../models/store.dart';
import '../services/spring_service.dart';

class StoreItem extends StatefulWidget {
  const StoreItem({
    Key? key,
    required this.store,
    required this.onTap,
  }) : super(key: key);

  final Store store;

  final void Function() onTap;

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

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    return Material(
      color: theme.backgroundColor,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: const BorderRadius.all(Radius.circular(24)),
          highlightColor: theme.primaryColorLight.withOpacity(.1),
          splashColor: theme.primaryColorLight.withOpacity(.1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                color:
                    theme.brightness == Brightness.dark ? Colors.white : null,
                padding: theme.brightness == Brightness.dark
                    ? const EdgeInsets.all(4)
                    : null,
                child: Image.network(widget.store.logo, height: 50, width: 50),
              ),
              const SizedBox(height: 8),
              Text(
                widget.store.name,
                style: textTheme.headline6!.copyWith(
                  color: theme.primaryColor,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              FutureBuilder<int?>(
                future: numberOfDealsFuture,
                builder: (BuildContext context, AsyncSnapshot<int?> snapshot) {
                  String dealsText = '...';

                  if (snapshot.hasData) {
                    dealsText = snapshot.data!.toString();
                  } else if (snapshot.hasError) {
                    print(snapshot.error.toString());
                  }

                  return Text(
                    '$dealsText Fırsat',
                    style: textTheme.subtitle2!
                        .copyWith(color: theme.primaryColorLight),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
