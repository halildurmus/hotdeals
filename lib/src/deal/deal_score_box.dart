import 'package:flutter/material.dart';

class DealScoreBox extends StatelessWidget {
  const DealScoreBox({required this.score, Key? key}) : super(key: key);

  final int score;

  Color _getBoxColor(int dealScore) {
    if (dealScore < 0) {
      return Colors.red;
    } else if (dealScore == 0) {
      return Colors.grey;
    }

    return const Color(0xFF006400).withOpacity(.8);
  }

  String _getDealScore() => score > 0 ? '+$score' : score.toString();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        color: _getBoxColor(score),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      child: Text(
        _getDealScore(),
        style: textTheme.bodyText2!.copyWith(color: Colors.green.shade50),
      ),
    );
  }
}
