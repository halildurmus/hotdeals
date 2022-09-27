import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

import '../helpers/context_extensions.dart';

class ExpandableText extends StatefulWidget {
  const ExpandableText({
    required this.text,
    this.maxLines = 4,
    this.padding = const EdgeInsets.all(16),
    super.key,
  });

  final int maxLines;
  final EdgeInsets padding;
  final String text;

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
    final textStyle = context.textTheme.bodyText2!.copyWith(
      color: context.isDarkMode ? Colors.grey : null,
      fontSize: 15,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final textPainter = TextPainter(
          maxLines: widget.maxLines,
          text: TextSpan(text: widget.text, style: textStyle),
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

        return ExpandableNotifier(
          controller: controller,
          child: ScrollOnExpand(
            child: Expandable(
              collapsed: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Padding(
                    padding: widget.padding,
                    child: Text(
                      widget.text,
                      maxLines: widget.maxLines,
                      overflow: TextOverflow.fade,
                      style: textStyle,
                    ),
                  ),
                  Positioned(
                    bottom: 5,
                    child: InkWell(
                      onTap: controller.toggle,
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: controller.toggle,
                            icon: Icon(
                              Icons.arrow_downward,
                              color: context.isDarkMode
                                  ? null
                                  : context.textTheme.bodyText2!.color,
                              size: 16,
                            ),
                            label: Text(
                              context.l.readMore,
                              style: context.textTheme.bodyText2!
                                  .copyWith(fontSize: 15),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.isDarkMode
                                  ? const Color(0xFF2e2d2d)
                                  : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              expanded: Padding(
                padding: widget.padding,
                child: SelectableText(widget.text, style: textStyle),
              ),
            ),
          ),
        );
      },
    );
  }
}
