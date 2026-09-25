import 'package:flutter/widgets.dart';

/// Layout breakpoints *in addition to* `.w` / `.h` scaling.
///
/// Use `.w` for Figma-matched chrome on phones; use these for fluid layout
/// switches on tablets (e.g. drawer vs rail) with `Expanded` / `Flexible`.
enum VorzelaBreakpoint {
  compact,
  medium,
  expanded,
}

/// Material-ish defaults: compact &lt; 600, medium &lt; 840, else expanded.
abstract final class VorzelaBreakpoints {
  static const double compactMax = 600;
  static const double mediumMax = 840;

  /// Width below which devices are treated as watch-class (still clamped).
  static const double watchMax = 300;

  static VorzelaBreakpoint of(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w < compactMax) return VorzelaBreakpoint.compact;
    if (w < mediumMax) return VorzelaBreakpoint.medium;
    return VorzelaBreakpoint.expanded;
  }

  static bool isCompact(BuildContext context) =>
      of(context) == VorzelaBreakpoint.compact;

  static bool isMedium(BuildContext context) =>
      of(context) == VorzelaBreakpoint.medium;

  static bool isExpanded(BuildContext context) =>
      of(context) == VorzelaBreakpoint.expanded;

  static bool isWatchWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width < watchMax;
}

typedef VorzelaAdaptiveWidgetBuilder = Widget Function(
  BuildContext context,
  VorzelaBreakpoint breakpoint,
);

/// Switches layout by [VorzelaBreakpoint] — use on tablets instead of growing `.sp`.
///
/// ```dart
/// VorzelaAdaptiveBuilder(
///   compact: (c, _) => PhoneScaffold(),
///   medium: (c, _) => TabletScaffold(rail: true),
///   expanded: (c, _) => DesktopScaffold(),
/// )
/// ```
class VorzelaAdaptiveBuilder extends StatelessWidget {
  const VorzelaAdaptiveBuilder({
    super.key,
    required this.compact,
    this.medium,
    this.expanded,
  });

  final VorzelaAdaptiveWidgetBuilder compact;
  final VorzelaAdaptiveWidgetBuilder? medium;
  final VorzelaAdaptiveWidgetBuilder? expanded;

  @override
  Widget build(BuildContext context) {
    final bp = VorzelaBreakpoints.of(context);
    return switch (bp) {
      VorzelaBreakpoint.compact => compact(context, bp),
      VorzelaBreakpoint.medium =>
        (medium ?? compact)(context, bp),
      VorzelaBreakpoint.expanded =>
        (expanded ?? medium ?? compact)(context, bp),
    };
  }
}
