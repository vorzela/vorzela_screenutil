# vorzela_screenutil

Fast, ScreenUtil-compatible responsive scaling for Flutter (`.w` / `.h` / `.r` / `.sp`).

API-inspired by [flutter_screenutil](https://github.com/OpenFlutter/flutter_screenutil) (Apache-2.0); see [NOTICE](NOTICE).

## Phone-first scaling

| Knob | Default | Behavior |
|------|---------|----------|
| `minScale` | `0.85` | Floor — watch / tiny phones do not underscale to unreadable |
| `maxScale` | `1.2` | Cap — large phones do not explode `.w` / `.sp` |
| `freezeScaleAboveWidth` | `600` | Tablets / desktop: **scale = 1.0** — switch layout, do not grow text |

```dart
VorzelaScreenUtilInit(
  designSize: const Size(375, 812),
  minScale: 0.85,
  maxScale: 1.2,
  freezeScaleAboveWidth: 600,
  builder: (context, child) => MaterialApp(
    home: VorzelaAdaptiveBuilder(
      compact: (c, _) => PhoneHome(),   // use .w / .sp here
      medium: (c, _) => TabletHome(),   // rail / two-pane, scale frozen
      expanded: (c, _) => DesktopHome(),
    ),
  ),
);
```

## Why this fork

| Stock ScreenUtil | vorzela_screenutil |
|------------------|--------------------|
| Often ties rebuilds to full `MediaQuery` | Uses `MediaQuery.sizeOf` / `paddingOf` / `textScalerOf` |
| Unbounded growth on tablets | Freeze + AdaptiveBuilder |
| Text scale friction | Optional `respectTextScaler: true` (off by default) |

## Breakpoints

```dart
switch (VorzelaBreakpoints.of(context)) {
  case VorzelaBreakpoint.compact: // < 600
  case VorzelaBreakpoint.medium:  // < 840
  case VorzelaBreakpoint.expanded:
}
```

Use `.w` for Figma-matched **phone** chrome; use `VorzelaAdaptiveBuilder` + `Expanded` / `Flexible` on tablets.
