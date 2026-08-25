import 'package:flutter/material.dart';

/// Shared phone breakpoints and spacing for NeoRider layouts.
@immutable
class NeoResponsive {
  const NeoResponsive._(this.size, this.viewPadding);

  factory NeoResponsive.of(BuildContext context) => NeoResponsive._(
    MediaQuery.sizeOf(context),
    MediaQuery.paddingOf(context),
  );

  final Size size;
  final EdgeInsets viewPadding;

  double get width => size.width;
  double get height => size.height;
  bool get isSmallPhone => width < 360;
  bool get isLargePhone => width >= 430;

  double get horizontalPadding => isSmallPhone ? 14 : (isLargePhone ? 24 : 18);
  double get sectionSpacing => isSmallPhone ? 14 : 18;
  double get cardPadding => isSmallPhone ? 16 : 22;
  double get radius => isSmallPhone ? 18 : 22;
  double get pageTitleSize => (width * 0.085).clamp(28.0, 40.0);
  double get bottomNavClearance => viewPadding.bottom + 96;

  EdgeInsets get pagePadding => EdgeInsets.fromLTRB(
    horizontalPadding,
    sectionSpacing,
    horizontalPadding,
    bottomNavClearance,
  );
}
