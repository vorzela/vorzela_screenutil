# Changelog

## 0.1.1

- `minScale` / `maxScale` clamps (defaults 0.85 / 1.2).
- `freezeScaleAboveWidth` (default 600) freezes design scale on tablets.
- `VorzelaAdaptiveBuilder` for compact / medium / expanded layouts.

## 0.1.0

- Initial release: ScreenUtil-compatible `.w` / `.h` / `.r` / `.sp` API.
- `VorzelaScreenUtilInit` / `ScreenUtilInit` with `MediaQuery.sizeOf` and
  cached scale ratios.
- Optional `respectTextScaler` for a11y-aware `.sp`.
- `VorzelaBreakpoints` helpers (~600 / ~840).
