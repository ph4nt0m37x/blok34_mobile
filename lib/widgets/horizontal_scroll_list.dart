// widgets/horizontal_scroll_list.dart
import 'package:flutter/material.dart';

class HorizontalScrollList<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext, T) itemBuilder;
  final double itemWidth;
  final double itemHeight;
  final double spacing;
  final EdgeInsets padding;
  final String? title;
  final IconData? titleIcon;
  final Widget? emptyStateWidget;
  final VoidCallback? onSeeAllTap;

  const HorizontalScrollList({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.itemWidth = 300,
    this.itemHeight = 330,
    this.spacing = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
    this.title,
    this.titleIcon,
    this.emptyStateWidget,
    this.onSeeAllTap,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return emptyStateWidget ?? const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                if (titleIcon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.cyan.shade400.withValues(alpha: 0.3),
                        width: 0.5,
                      ),
                    ),
                    child: Icon(titleIcon, size: 16, color: Colors.lightBlueAccent),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Text(
                    title!,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (onSeeAllTap != null)
                  TextButton(
                    onPressed: onSeeAllTap,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                    ),
                    child: Text(
                      "See All →",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.cyan.shade300,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        SizedBox(
          height: itemHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: padding,
            itemCount: items.length,
            itemBuilder: (context, index) {
              return SizedBox(
                width: itemWidth,
                child: Padding(
                  padding: EdgeInsets.only(right: index == items.length - 1 ? 0 : spacing),
                  child: itemBuilder(context, items[index]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}