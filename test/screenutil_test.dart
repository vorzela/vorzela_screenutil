import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vorzela_screenutil/vorzela_screenutil.dart';

void main() {
  testWidgets('phone scales within maxScale clamp', (tester) async {
    // Raw width scale 500/360 ≈ 1.39 → clamped to 1.2
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(500, 900)),
        child: VorzelaScreenUtilInit(
          designSize: const Size(360, 690),
          builder: (context, child) {
            return MaterialApp(
              home: Scaffold(
                body: Text('${100.w}|${ScreenUtil().scaleWidth}'),
              ),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(ScreenUtil().scaleWidth, 1.2);
    expect(find.textContaining('120.0'), findsOneWidget);
  });

  testWidgets('tablet freezes scale at 1.0', (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(1024, 768)),
        child: VorzelaScreenUtilInit(
          designSize: const Size(360, 690),
          builder: (context, child) {
            return MaterialApp(
              home: Scaffold(body: Text('${100.w}')),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(ScreenUtil().isScaleFrozen, isTrue);
    expect(ScreenUtil().scaleWidth, 1.0);
    expect(find.text('100.0'), findsOneWidget);
  });

  testWidgets('tiny width respects minScale floor', (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(280, 280)),
        child: VorzelaScreenUtilInit(
          designSize: const Size(360, 690),
          builder: (context, child) {
            return const MaterialApp(home: SizedBox());
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(ScreenUtil().scaleWidth, greaterThanOrEqualTo(0.85));
    expect(100.w, greaterThanOrEqualTo(85));
  });

  testWidgets('respectTextScaler multiplies .sp', (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(360, 690),
          textScaler: TextScaler.linear(2.0),
        ),
        child: VorzelaScreenUtilInit(
          designSize: const Size(360, 690),
          respectTextScaler: true,
          builder: (context, child) {
            return MaterialApp(
              home: Scaffold(body: Text('${10.sp}')),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('20.0'), findsOneWidget);
  });

  testWidgets('VorzelaAdaptiveBuilder switches by breakpoint', (tester) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(size: Size(800, 600)),
        child: MaterialApp(
          home: VorzelaAdaptiveBuilder(
            compact: _compact,
            medium: _medium,
            expanded: _expanded,
          ),
        ),
      ),
    );
    expect(find.text('MEDIUM'), findsOneWidget);
  });

  testWidgets('breakpoint helpers', (tester) async {
    late VorzelaBreakpoint bp;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(800, 600)),
        child: Builder(
          builder: (context) {
            bp = VorzelaBreakpoints.of(context);
            return const SizedBox();
          },
        ),
      ),
    );
    expect(bp, VorzelaBreakpoint.medium);
  });
}

Widget _compact(BuildContext context, VorzelaBreakpoint bp) =>
    const Text('COMPACT');

Widget _medium(BuildContext context, VorzelaBreakpoint bp) =>
    const Text('MEDIUM');

Widget _expanded(BuildContext context, VorzelaBreakpoint bp) =>
    const Text('EXPANDED');
