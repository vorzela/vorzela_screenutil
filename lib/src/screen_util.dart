import 'dart:math' show max, min;
import 'dart:ui' as ui show FlutterView;

import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/widgets.dart';

typedef FontSizeResolver = double Function(num fontSize, ScreenUtil instance);

/// Singleton scale holder — API-compatible with flutter_screenutil's [ScreenUtil].
///
/// Prefer reading scales after [VorzelaScreenUtilInit] / [ScreenUtil.init].
/// Extensions (`.w` / `.h` / `.sp`) call this singleton; no per-widget allocation.
///
/// **Phone-first:** scales are clamped with [minScale]/[maxScale]. At/above
/// [freezeScaleAboveWidth] (tablets), design scale freezes at `1.0` — switch
/// layout with [VorzelaAdaptiveBuilder], do not inflate text.
class ScreenUtil {
  static const Size defaultSize = Size(360, 690);
  static const double defaultMinScale = 0.85;
  static const double defaultMaxScale = 1.2;
  static const double defaultFreezeScaleAboveWidth = 600;
  static const double defaultWatchWidth = 300;

  static final ScreenUtil _instance = ScreenUtil._();

  static bool Function() _enableScaleWH = () => true;
  static bool Function() _enableScaleText = () => true;

  ScreenUtil._();

  factory ScreenUtil() => _instance;

  Size _uiSize = defaultSize;
  Orientation _orientation = Orientation.portrait;
  bool _minTextAdapt = false;
  bool _splitScreenMode = false;
  bool _respectTextScaler = false;
  double _textScaler = 1.0;
  Size _screenSize = defaultSize;
  double _devicePixelRatio = 1.0;
  EdgeInsets _padding = EdgeInsets.zero;
  FontSizeResolver? fontSizeResolver;

  double _minScale = defaultMinScale;
  double _maxScale = defaultMaxScale;
  double _freezeScaleAboveWidth = defaultFreezeScaleAboveWidth;

  // Cached ratios — invalidated only when size / design / flags change.
  double _scaleWidth = 1.0;
  double _scaleHeight = 1.0;
  double _scaleText = 1.0;
  bool _configured = false;
  bool _scaleFrozen = false;

  static void enableScale({
    bool Function()? enableWH,
    bool Function()? enableText,
  }) {
    _enableScaleWH = enableWH ?? () => true;
    _enableScaleText = enableText ?? () => true;
    _instance._recomputeScales();
  }

  static Future<void> ensureScreenSize([
    ui.FlutterView? window,
    Duration duration = const Duration(milliseconds: 10),
  ]) async {
    final binding = WidgetsFlutterBinding.ensureInitialized();
    binding.deferFirstFrame();
    await Future.doWhile(() {
      window ??= binding.platformDispatcher.implicitView;
      if (window == null || window!.physicalSize.isEmpty) {
        return Future<bool>.delayed(duration, () => true);
      }
      return false;
    });
    binding.allowFirstFrame();
  }

  /// Apply metrics. Prefer [size] + [padding] + [textScaler] over full
  /// [MediaQueryData] so callers can use `sizeOf` / `paddingOf` / `textScalerOf`.
  static void configure({
    Size? size,
    EdgeInsets? padding,
    double? devicePixelRatio,
    double? textScaler,
    Orientation? orientation,
    MediaQueryData? data,
    Size? designSize,
    bool? splitScreenMode,
    bool? minTextAdapt,
    bool? respectTextScaler,
    double? minScale,
    double? maxScale,
    double? freezeScaleAboveWidth,
    FontSizeResolver? fontSizeResolver,
  }) {
    final i = _instance;
    if (data != null) {
      final s = data.size;
      if (!s.isEmpty) {
        i._screenSize = s;
        i._padding = data.padding;
        i._devicePixelRatio = data.devicePixelRatio;
        i._textScaler = data.textScaler.scale(1.0);
        i._orientation = data.orientation;
      }
    }
    if (size != null && !size.isEmpty) {
      i._screenSize = size;
      i._orientation = orientation ??
          (size.width > size.height
              ? Orientation.landscape
              : Orientation.portrait);
    }
    if (padding != null) i._padding = padding;
    if (devicePixelRatio != null) i._devicePixelRatio = devicePixelRatio;
    if (textScaler != null) i._textScaler = textScaler;
    if (orientation != null) i._orientation = orientation;
    if (designSize != null) i._uiSize = designSize;
    if (splitScreenMode != null) i._splitScreenMode = splitScreenMode;
    if (minTextAdapt != null) i._minTextAdapt = minTextAdapt;
    if (respectTextScaler != null) i._respectTextScaler = respectTextScaler;
    if (minScale != null) i._minScale = minScale;
    if (maxScale != null) i._maxScale = maxScale;
    if (freezeScaleAboveWidth != null) {
      i._freezeScaleAboveWidth = freezeScaleAboveWidth;
    }
    if (fontSizeResolver != null) i.fontSizeResolver = fontSizeResolver;
    i._configured = true;
    i._recomputeScales();
  }

  static void init(
    BuildContext context, {
    Size designSize = defaultSize,
    bool splitScreenMode = false,
    bool minTextAdapt = false,
    bool respectTextScaler = false,
    double minScale = defaultMinScale,
    double maxScale = defaultMaxScale,
    double freezeScaleAboveWidth = defaultFreezeScaleAboveWidth,
    FontSizeResolver? fontSizeResolver,
  }) {
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final scaler = MediaQuery.textScalerOf(context).scale(1.0);
    final orientation = MediaQuery.orientationOf(context);
    configure(
      size: size,
      padding: padding,
      devicePixelRatio: dpr,
      textScaler: scaler,
      orientation: orientation,
      designSize: designSize,
      splitScreenMode: splitScreenMode,
      minTextAdapt: minTextAdapt,
      respectTextScaler: respectTextScaler,
      minScale: minScale,
      maxScale: maxScale,
      freezeScaleAboveWidth: freezeScaleAboveWidth,
      fontSizeResolver: fontSizeResolver,
    );
  }

  static Future<void> ensureScreenSizeAndInit(
    BuildContext context, {
    Size designSize = defaultSize,
    bool splitScreenMode = false,
    bool minTextAdapt = false,
    bool respectTextScaler = false,
    double minScale = defaultMinScale,
    double maxScale = defaultMaxScale,
    double freezeScaleAboveWidth = defaultFreezeScaleAboveWidth,
    FontSizeResolver? fontSizeResolver,
  }) async {
    await ensureScreenSize();
    if (!context.mounted) return;
    init(
      context,
      designSize: designSize,
      splitScreenMode: splitScreenMode,
      minTextAdapt: minTextAdapt,
      respectTextScaler: respectTextScaler,
      minScale: minScale,
      maxScale: maxScale,
      freezeScaleAboveWidth: freezeScaleAboveWidth,
      fontSizeResolver: fontSizeResolver,
    );
  }

  double _clampScale(double raw) {
    if (raw < _minScale) return _minScale;
    if (raw > _maxScale) return _maxScale;
    return raw;
  }

  void _recomputeScales() {
    final wh = _enableScaleWH();
    final text = _enableScaleText();

    // Tablets / wide layouts: freeze design scale — use AdaptiveBuilder for UI.
    if (_screenSize.width >= _freezeScaleAboveWidth) {
      _scaleFrozen = true;
      _scaleWidth = 1.0;
      _scaleHeight = 1.0;
      _scaleText = 1.0;
      return;
    }
    _scaleFrozen = false;

    var sw = wh ? _screenSize.width / _uiSize.width : 1.0;
    final h = _splitScreenMode
        ? max(_screenSize.height, 700.0)
        : _screenSize.height;
    var sh = wh ? h / _uiSize.height : 1.0;
    sw = _clampScale(sw);
    sh = _clampScale(sh);
    _scaleWidth = sw;
    _scaleHeight = sh;
    _scaleText = text
        ? (_minTextAdapt ? min(_scaleWidth, _scaleHeight) : _scaleWidth)
        : 1.0;
  }

  bool get isConfigured => _configured;

  /// True when width ≥ [freezeScaleAboveWidth] (tablet / desktop).
  bool get isScaleFrozen => _scaleFrozen;

  double get minScale => _minScale;

  double get maxScale => _maxScale;

  double get freezeScaleAboveWidth => _freezeScaleAboveWidth;

  Orientation get orientation => _orientation;

  @Deprecated('Use textScaler')
  double get textScaleFactor => _textScaler;

  double get textScaler => _textScaler;

  double? get pixelRatio => _devicePixelRatio;

  double get screenWidth => _screenSize.width;

  double get screenHeight => _screenSize.height;

  double get statusBarHeight => _padding.top;

  double get bottomBarHeight => _padding.bottom;

  double get scaleWidth => _scaleWidth;

  double get scaleHeight => _scaleHeight;

  double get scaleText => _scaleText;

  double setWidth(num width) => width * _scaleWidth;

  double setHeight(num height) => height * _scaleHeight;

  double radius(num r) => r * min(_scaleWidth, _scaleHeight);

  double diagonal(num d) => d * _scaleHeight * _scaleWidth;

  double diameter(num d) => d * max(_scaleWidth, _scaleHeight);

  double setSp(num fontSize) {
    final base =
        fontSizeResolver?.call(fontSize, _instance) ?? fontSize * _scaleText;
    return _respectTextScaler ? base * _textScaler : base;
  }

  DeviceType deviceType([BuildContext? context]) {
    if (kIsWeb) return DeviceType.web;
    final w = context != null ? MediaQuery.sizeOf(context).width : screenWidth;
    final h =
        context != null ? MediaQuery.sizeOf(context).height : screenHeight;
    final o = context != null
        ? MediaQuery.orientationOf(context)
        : orientation;
    final isMobile = defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android;
    final isTablet = (o == Orientation.portrait && w >= 600) ||
        (o == Orientation.landscape && h >= 600);
    if (isMobile) {
      return isTablet ? DeviceType.tablet : DeviceType.mobile;
    }
    return switch (defaultTargetPlatform) {
      TargetPlatform.linux => DeviceType.linux,
      TargetPlatform.macOS => DeviceType.mac,
      TargetPlatform.windows => DeviceType.windows,
      TargetPlatform.fuchsia => DeviceType.fuchsia,
      _ => DeviceType.mobile,
    };
  }

  SizedBox setVerticalSpacing(num height) =>
      SizedBox(height: setHeight(height));

  SizedBox setVerticalSpacingFromWidth(num height) =>
      SizedBox(height: setWidth(height));

  SizedBox setHorizontalSpacing(num width) => SizedBox(width: setWidth(width));

  SizedBox setHorizontalSpacingRadius(num width) =>
      SizedBox(width: radius(width));

  SizedBox setVerticalSpacingRadius(num height) =>
      SizedBox(height: radius(height));

  SizedBox setHorizontalSpacingDiameter(num width) =>
      SizedBox(width: diameter(width));

  SizedBox setVerticalSpacingDiameter(num height) =>
      SizedBox(height: diameter(height));

  SizedBox setHorizontalSpacingDiagonal(num width) =>
      SizedBox(width: diagonal(width));

  SizedBox setVerticalSpacingDiagonal(num height) =>
      SizedBox(height: diagonal(height));
}

enum DeviceType { mobile, tablet, web, mac, windows, linux, fuchsia }

abstract final class FontSizeResolvers {
  static double width(num fontSize, ScreenUtil instance) =>
      instance.setWidth(fontSize);

  static double height(num fontSize, ScreenUtil instance) =>
      instance.setHeight(fontSize);

  static double radius(num fontSize, ScreenUtil instance) =>
      instance.radius(fontSize);

  static double diameter(num fontSize, ScreenUtil instance) =>
      instance.diameter(fontSize);

  static double diagonal(num fontSize, ScreenUtil instance) =>
      instance.diagonal(fontSize);
}
