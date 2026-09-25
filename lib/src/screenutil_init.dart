import 'package:flutter/widgets.dart';

import 'screen_util.dart';

typedef RebuildFactor = bool Function(Size oldSize, Size newSize);

typedef ScreenUtilInitBuilder = Widget Function(
  BuildContext context,
  Widget? child,
);

/// When to rebuild descendants after a metrics change.
///
/// Defaults to **size only** — avoids rebuilding on keyboard insets / text
/// scale (unlike stock ScreenUtilInit which can listen to full MediaQuery).
abstract final class RebuildFactors {
  static bool size(Size oldSize, Size newSize) => oldSize != newSize;

  static bool always(Size _, Size __) => true;

  static bool none(Size _, Size __) => false;
}

/// Initializes [ScreenUtil] from granular MediaQuery lookups.
///
/// Alias: [ScreenUtilInit].
class VorzelaScreenUtilInit extends StatefulWidget {
  const VorzelaScreenUtilInit({
    super.key,
    this.builder,
    this.child,
    this.rebuildFactor = RebuildFactors.size,
    this.designSize = ScreenUtil.defaultSize,
    this.splitScreenMode = false,
    this.minTextAdapt = false,
    this.respectTextScaler = false,
    this.minScale = ScreenUtil.defaultMinScale,
    this.maxScale = ScreenUtil.defaultMaxScale,
    this.freezeScaleAboveWidth = ScreenUtil.defaultFreezeScaleAboveWidth,
    this.ensureScreenSize = false,
    this.enableScaleWH,
    this.enableScaleText,
    this.fontSizeResolver = FontSizeResolvers.width,
  });

  final ScreenUtilInitBuilder? builder;
  final Widget? child;
  final RebuildFactor rebuildFactor;
  final Size designSize;
  final bool splitScreenMode;
  final bool minTextAdapt;

  /// When true, `.sp` multiplies design scale × system [TextScaler] (a11y).
  final bool respectTextScaler;

  /// Floor for width/height scale (watch / tiny phones). Default `0.85`.
  final double minScale;

  /// Cap so large phones do not explode `.w`/`.sp`. Default `1.2`.
  final double maxScale;

  /// At/above this width, scale freezes at `1.0` (tablet / desktop).
  final double freezeScaleAboveWidth;

  final bool ensureScreenSize;
  final bool Function()? enableScaleWH;
  final bool Function()? enableScaleText;
  final FontSizeResolver fontSizeResolver;

  @override
  State<VorzelaScreenUtilInit> createState() => _VorzelaScreenUtilInitState();
}

/// flutter_screenutil-compatible name for [VorzelaScreenUtilInit].
typedef ScreenUtilInit = VorzelaScreenUtilInit;

class _VorzelaScreenUtilInitState extends State<VorzelaScreenUtilInit>
    with WidgetsBindingObserver {
  Size? _lastSize;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    ScreenUtil.enableScale(
      enableWH: widget.enableScaleWH,
      enableText: widget.enableScaleText,
    );
    WidgetsBinding.instance.addObserver(this);
    if (widget.ensureScreenSize) {
      ScreenUtil.ensureScreenSize().then((_) {
        if (mounted) setState(() => _ready = true);
      });
    } else {
      _ready = true;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    if (mounted) setState(() {});
  }

  void _apply(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final scaler = MediaQuery.textScalerOf(context).scale(1.0);
    final orientation = MediaQuery.orientationOf(context);

    _lastSize = size;

    ScreenUtil.configure(
      size: size,
      padding: padding,
      devicePixelRatio: dpr,
      textScaler: scaler,
      orientation: orientation,
      designSize: widget.designSize,
      splitScreenMode: widget.splitScreenMode,
      minTextAdapt: widget.minTextAdapt,
      respectTextScaler: widget.respectTextScaler,
      minScale: widget.minScale,
      maxScale: widget.maxScale,
      freezeScaleAboveWidth: widget.freezeScaleAboveWidth,
      fontSizeResolver: widget.fontSizeResolver,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) return const SizedBox.shrink();
    _apply(context);
    return widget.builder?.call(context, widget.child) ?? widget.child!;
  }
}
