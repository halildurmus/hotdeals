import 'package:flutter/material.dart';

class ModalHandle extends StatelessWidget {
  const ModalHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: .2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: SizedBox(
          height: 5,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2.5),
              color: Theme.of(context).dividerColor,
            ),
          ),
        ),
      ),
    );
  }
}
