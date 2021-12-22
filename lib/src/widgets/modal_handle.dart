import 'package:flutter/material.dart';

class ModalHandle extends StatelessWidget {
  const ModalHandle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => FractionallySizedBox(
        widthFactor: .2,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          child: SizedBox(
            height: 5,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: const BorderRadius.all(Radius.circular(2.5)),
              ),
            ),
          ),
        ),
      );
}
