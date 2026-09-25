import 'dart:math';

import 'package:flutter/widgets.dart';

import 'screen_util.dart';

extension SizeExtension on num {
  /// Design-width → device width.
  double get w => ScreenUtil().setWidth(this);

  /// Design-height → device height.
  double get h => ScreenUtil().setHeight(this);

  /// Radius / square side (min of width/height scales).
  double get r => ScreenUtil().radius(this);

  double get dg => ScreenUtil().diagonal(this);

  double get dm => ScreenUtil().diameter(this);

  /// Scaled font size (optionally × TextScaler when enabled on init).
  double get sp => ScreenUtil().setSp(this);

  double get spMin => min(toDouble(), sp);

  @Deprecated('use spMin instead')
  double get sm => min(toDouble(), sp);

  double get spMax => max(toDouble(), sp);

  /// Fraction of screen width (`0.5.sw` = half screen).
  double get sw => ScreenUtil().screenWidth * this;

  /// Fraction of screen height.
  double get sh => ScreenUtil().screenHeight * this;

  SizedBox get verticalSpace => ScreenUtil().setVerticalSpacing(this);

  SizedBox get verticalSpaceFromWidth =>
      ScreenUtil().setVerticalSpacingFromWidth(this);

  SizedBox get horizontalSpace => ScreenUtil().setHorizontalSpacing(this);

  SizedBox get horizontalSpaceRadius =>
      ScreenUtil().setHorizontalSpacingRadius(this);

  SizedBox get verticalSpacingRadius =>
      ScreenUtil().setVerticalSpacingRadius(this);

  SizedBox get horizontalSpaceDiameter =>
      ScreenUtil().setHorizontalSpacingDiameter(this);

  SizedBox get verticalSpacingDiameter =>
      ScreenUtil().setVerticalSpacingDiameter(this);

  SizedBox get horizontalSpaceDiagonal =>
      ScreenUtil().setHorizontalSpacingDiagonal(this);

  SizedBox get verticalSpacingDiagonal =>
      ScreenUtil().setVerticalSpacingDiagonal(this);
}

extension EdgeInsetsExtension on EdgeInsets {
  EdgeInsets get r => copyWith(
        top: top.r,
        bottom: bottom.r,
        right: right.r,
        left: left.r,
      );

  EdgeInsets get dm => copyWith(
        top: top.dm,
        bottom: bottom.dm,
        right: right.dm,
        left: left.dm,
      );

  EdgeInsets get dg => copyWith(
        top: top.dg,
        bottom: bottom.dg,
        right: right.dg,
        left: left.dg,
      );

  EdgeInsets get w => copyWith(
        top: top.w,
        bottom: bottom.w,
        right: right.w,
        left: left.w,
      );

  EdgeInsets get h => copyWith(
        top: top.h,
        bottom: bottom.h,
        right: right.h,
        left: left.h,
      );
}

extension BorderRadiusExtension on BorderRadius {
  BorderRadius get r => copyWith(
        bottomLeft: bottomLeft.r,
        bottomRight: bottomRight.r,
        topLeft: topLeft.r,
        topRight: topRight.r,
      );

  BorderRadius get w => copyWith(
        bottomLeft: bottomLeft.w,
        bottomRight: bottomRight.w,
        topLeft: topLeft.w,
        topRight: topRight.w,
      );

  BorderRadius get h => copyWith(
        bottomLeft: bottomLeft.h,
        bottomRight: bottomRight.h,
        topLeft: topLeft.h,
        topRight: topRight.h,
      );
}

extension RadiusExtension on Radius {
  Radius get r => Radius.elliptical(x.r, y.r);

  Radius get dm => Radius.elliptical(x.dm, y.dm);

  Radius get dg => Radius.elliptical(x.dg, y.dg);

  Radius get w => Radius.elliptical(x.w, y.w);

  Radius get h => Radius.elliptical(x.h, y.h);
}

extension BoxConstraintsExtension on BoxConstraints {
  BoxConstraints get r => copyWith(
        maxHeight: maxHeight.r,
        maxWidth: maxWidth.r,
        minHeight: minHeight.r,
        minWidth: minWidth.r,
      );

  BoxConstraints get hw => copyWith(
        maxHeight: maxHeight.h,
        maxWidth: maxWidth.w,
        minHeight: minHeight.h,
        minWidth: minWidth.w,
      );

  BoxConstraints get w => copyWith(
        maxHeight: maxHeight.w,
        maxWidth: maxWidth.w,
        minHeight: minHeight.w,
        minWidth: minWidth.w,
      );

  BoxConstraints get h => copyWith(
        maxHeight: maxHeight.h,
        maxWidth: maxWidth.h,
        minHeight: minHeight.h,
        minWidth: minWidth.h,
      );
}
