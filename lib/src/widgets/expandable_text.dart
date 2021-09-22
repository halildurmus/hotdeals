import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ExpandableText extends StatelessWidget {
  const ExpandableText({
    Key? key,
    required this.text,
    this.maxLines = 4,
    this.padding = const EdgeInsets.all(16),
  }) : super(key: key);

  final String text;
  final int maxLines;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final textStyle = textTheme.bodyText2!.copyWith(
      color: theme.brightness == Brightness.dark ? Colors.grey : null,
      fontSize: 15,
    );
    final expandTextStyle = textTheme.bodyText2!.copyWith(
      color: theme.primaryColor,
      fontSize: 13,
    );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final TextPainter textPainter = TextPainter(
          text: TextSpan(text: text, style: textStyle),
          maxLines: maxLines,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);

        if (!textPainter.didExceedMaxLines) {
          return Padding(
            padding: padding,
            child: Align(
              alignment: Alignment.centerLeft,
              child: SelectableText(text, style: textStyle),
            ),
          );
        }

        return Padding(
          padding: padding,
          child: ExpandableNotifier(
            child: ScrollOnExpand(
              child: Expandable(
                collapsed: Column(
                  children: [
                    Text(
                      text,
                      maxLines: maxLines,
                      overflow: TextOverflow.fade,
                      style: textStyle,
                    ),
                    const SizedBox(height: 10),
                    ExpandableButton(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.readMore,
                            style: expandTextStyle,
                          ),
                          Icon(Icons.expand_more, color: theme.primaryColor),
                        ],
                      ),
                    ),
                  ],
                ),
                expanded: Column(
                  children: [
                    SelectableText(text, style: textStyle),
                    const SizedBox(height: 10),
                    ExpandableButton(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.readLess,
                            style: expandTextStyle,
                          ),
                          Icon(Icons.expand_less, color: theme.primaryColor),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
