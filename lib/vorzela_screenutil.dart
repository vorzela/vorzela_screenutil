/// Fast ScreenUtil-compatible responsive scaling for Flutter.
///
/// API-compatible with flutter_screenutil (`.w` / `.h` / `.sp` / `ScreenUtilInit`)
/// with fewer rebuilds via [MediaQuery.sizeOf] and cached scale ratios.
library;

export 'src/breakpoints.dart';
export 'src/screen_util.dart';
export 'src/screenutil_init.dart';
export 'src/size_extension.dart';
