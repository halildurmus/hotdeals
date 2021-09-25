import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ExpandableText extends StatefulWidget {
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
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  late final ExpandableController controller;

  @override
  void initState() {
    controller = ExpandableController();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

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
          text: TextSpan(text: widget.text, style: textStyle),
          maxLines: widget.maxLines,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);

        if (!textPainter.didExceedMaxLines) {
          return Padding(
            padding: widget.padding,
            child: Align(
              alignment: Alignment.centerLeft,
              child: SelectableText(widget.text, style: textStyle),
            ),
          );
        }

        Widget buildCollapsed() {
          return Column(
            children: [
              Text(
                widget.text,
                maxLines: widget.maxLines,
                overflow: TextOverflow.fade,
                style: textStyle,
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: () => controller.toggle(),
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
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
          );
        }

        Widget buildExpanded() {
          return Column(
            children: [
              SelectableText(widget.text, style: textStyle),
              const SizedBox(height: 10),
              InkWell(
                onTap: () => controller.toggle(),
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
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
          );
        }

        return Padding(
          padding: widget.padding,
          child: ExpandableNotifier(
            controller: controller,
            child: ScrollOnExpand(
              child: Expandable(
                collapsed: buildCollapsed(),
                expanded: buildExpanded(),
              ),
            ),
          ),
        );
      },
    );
  }
}
