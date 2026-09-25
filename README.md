# vorzela_screenutil

Fast, ScreenUtil-compatible responsive scaling for Flutter (`.w` / `.h` / `.r` / `.sp`).

API-inspired by [flutter_screenutil](https://github.com/OpenFlutter/flutter_screenutil) (Apache-2.0); see [NOTICE](NOTICE).

## When to use

| Situation | Use |
|-----------|-----|
| Phone UI must match a Figma design width (e.g. 375) | `.w` / `.h` / `.sp` under `VorzelaScreenUtilInit` |
| Tablet / desktop wider than ~600 logical px | **Do not scale text up** — scale freezes; switch layout with `VorzelaAdaptiveBuilder` |
| Watch / tiny width | `minScale` floor keeps chrome readable |
| Fluid lists / forms | Prefer `Expanded` / `Flexible` / breakpoints over more `.w` |

## Install

```yaml
dependencies:
  vorzela_screenutil:
    git:
      url: https://github.com/vorzela/vorzela_screenutil.git
```

```dart
import 'package:vorzela_screenutil/vorzela_screenutil.dart';
```

## Quick start

```dart
VorzelaScreenUtilInit( // alias: ScreenUtilInit
  designSize: const Size(375, 812),
  minScale: 0.85,
  maxScale: 1.2,
  freezeScaleAboveWidth: 600,
  // respectTextScaler: true, // a11y: .sp × system TextScaler
  builder: (context, child) => MaterialApp(
    home: VorzelaAdaptiveBuilder(
      compact: (c, _) => Scaffold(
        body: Padding(
          padding: EdgeInsets.all(16.w),
          child: Text('Hello', style: TextStyle(fontSize: 16.sp)),
        ),
      ),
      medium: (c, _) => TabletHome(),
      expanded: (c, _) => DesktopHome(),
    ),
  ),
);
```

## API reference

### Widgets

| API | When |
|-----|------|
| `VorzelaScreenUtilInit` / `ScreenUtilInit` | **Once** at app root. Reads `MediaQuery.sizeOf` / `paddingOf` / `textScalerOf`; caches scales. |
| `VorzelaAdaptiveBuilder` | Switch phone vs tablet vs desktop **layout** (not bigger fonts). Falls back: expanded → medium → compact. |

**Init knobs:** `designSize`, `minScale` (default `0.85`), `maxScale` (`1.2`), `freezeScaleAboveWidth` (`600`), `minTextAdapt`, `splitScreenMode`, `respectTextScaler`, `rebuildFactor`, `ensureScreenSize`, `fontSizeResolver`, `enableScaleWH` / `enableScaleText`.

### `ScreenUtil` singleton

| API | When |
|-----|------|
| `ScreenUtil()` | Read cached scales after init (extensions call this; avoid allocating wrappers yourself). |
| `ScreenUtil.init` / `configure` / `ensureScreenSize` | Manual bootstrap (tests, custom splash); prefer `VorzelaScreenUtilInit` in apps. |
| `setWidth` / `setHeight` / `setSp` / `radius` / `diagonal` / `diameter` | Same as `.w` / `.h` / `.sp` / `.r` / `.dg` / `.dm`. |
| `scaleWidth` / `scaleHeight` / `scaleText` | Inspect ratios; check `isScaleFrozen` on tablets. |
| `screenWidth` / `screenHeight` / `statusBarHeight` / `bottomBarHeight` | Layout math without another MediaQuery. |
| `deviceType([context])` | Coarse mobile/tablet/web/desktop enum. |
| Spacing helpers | `setVerticalSpacing`, `setHorizontalSpacing`, … → `SizedBox`s. |

### Extensions (`num`, `EdgeInsets`, `BorderRadius`, …)

| API | Meaning | When |
|-----|---------|------|
| `.w` | Design width → device | Padding, icon sizes, chrome on **phones** |
| `.h` | Design height → device | Vertical spacing that must match Figma |
| `.r` | `min(scaleW, scaleH)` | Radii / squares |
| `.sp` | Font size (× TextScaler if enabled) | Labels on phones |
| `.spMin` / `.spMax` | Clamp vs design | Cap growth / floor shrink |
| `.sw` / `.sh` | Fraction of screen | `0.5.sw` half width |
| `.verticalSpace` / `.horizontalSpace` | SizedBox | Quick gaps |
| `EdgeInsets` / `BorderRadius` / `BoxConstraints` `.w` `.h` `.r` | Adapt whole insets | Theme tokens |

### Breakpoints

| API | When |
|-----|------|
| `VorzelaBreakpoints.of(context)` → `compact` / `medium` / `expanded` | Layout switches (&lt;600 / &lt;840 / else) |
| `isCompact` / `isMedium` / `isExpanded` / `isWatchWidth` | Conditionals |
| `VorzelaBreakpoint` enum | Switch arms |

### Font resolvers

`FontSizeResolvers.width` (default) / `.height` / `.radius` / `.diameter` / `.diagonal` — pass as `fontSizeResolver` when `.sp` should follow a different axis.

## Phone-first scaling defaults

| Knob | Default | Behavior |
|------|---------|----------|
| `minScale` | `0.85` | Floor for tiny / watch-class widths |
| `maxScale` | `1.2` | Cap so large phones do not explode type |
| `freezeScaleAboveWidth` | `600` | Tablets: scale = `1.0` |

## Tests

```bash
cd vorzela_screenutil && flutter test
# includes screenutil_race_test.dart (rapid size churn)
```
