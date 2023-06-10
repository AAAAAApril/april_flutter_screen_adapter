import 'dart:ui';

extension SizeExt on Size {
  double devicePixelRatioByWidth(double designWidth) {
    return (width < height ? width : height) / designWidth;
  }
}
