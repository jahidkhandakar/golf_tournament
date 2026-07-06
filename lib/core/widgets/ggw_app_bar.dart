import 'package:flutter/material.dart';

/// Configurable top app bar shared across screens.
///
/// Screens plug in their own [leadingActions] (rendered left-to-right before
/// the title), [titleWidget], and [trailingActions] (rendered right-to-left
/// after the title) rather than each screen building its own AppBar from
/// scratch.
class GgwAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GgwAppBar({
    super.key,
    this.leadingActions = const [],
    this.titleWidget,
    this.trailingActions = const [],
  });

  final List<Widget> leadingActions;
  final Widget? titleWidget;
  final List<Widget> trailingActions;

  // Flutter's default IconButton lays out at kMinInteractiveDimension (48) —
  // using anything smaller here causes the leading Row to overflow.
  static const double _actionSlotWidth = kMinInteractiveDimension;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      titleSpacing: 0,
      leadingWidth: leadingActions.isEmpty ? null : _actionSlotWidth * leadingActions.length,
      leading: leadingActions.isEmpty
          ? null
          : Row(mainAxisAlignment: MainAxisAlignment.start, children: leadingActions),
      title: titleWidget,
      actions: trailingActions.isEmpty ? null : trailingActions,
    );
  }
}
