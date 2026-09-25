import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vorzela_screenutil/vorzela_screenutil.dart';

void main() {
  testWidgets('rapid size changes keep ScreenUtil consistent', (tester) async {
    var lastScale = 0.0;

    Future<void> pumpWithSize(Size size) async {
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(size: size),
          child: VorzelaScreenUtilInit(
            designSize: const Size(360, 690),
            builder: (context, child) {
              lastScale = ScreenUtil().scaleWidth;
              return MaterialApp(
                home: Scaffold(body: Text('${100.w}')),
              );
            },
          ),
        ),
      );
      await tester.pump();
    }

    await pumpWithSize(const Size(360, 690));
    expect(lastScale, closeTo(1.0, 0.01));
    expect(ScreenUtil().scaleWidth, closeTo(1.0, 0.01));

    await pumpWithSize(const Size(500, 900));
    expect(lastScale, 1.2);
    expect(ScreenUtil().scaleWidth, 1.2);

    await pumpWithSize(const Size(280, 560));
    expect(ScreenUtil().scaleWidth, greaterThanOrEqualTo(0.85));
    expect(lastScale, ScreenUtil().scaleWidth);
  });

  testWidgets('nested pumps during init do not throw', (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(400, 800)),
        child: VorzelaScreenUtilInit(
          designSize: const Size(360, 690),
          builder: (context, child) => MaterialApp(
            home: Builder(
              builder: (context) {
                ScreenUtil.init(context);
                return Text('${50.w}');
              },
            ),
          ),
        ),
      ),
    );
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(ScreenUtil().isConfigured, isTrue);
  });
}
