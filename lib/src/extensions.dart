import 'dart:ui';

import 'package:flutter/widgets.dart';

extension SizeExt on Size {
  double devicePixelRatioByWidth(double designWidth) {
    return (width < height ? width : height) / designWidth;
  }
}

extension BuildContextExt on BuildContext {
  MediaQueryData adaptMediaQueryDataByDesignWidth(double designWidth) {
    final FlutterView view = View.of(this);
    final double devicePixelRatio = view.physicalSize.devicePixelRatioByWidth(designWidth);
    return MediaQuery.of(this).copyWith(
      size: view.physicalSize / devicePixelRatio,
      devicePixelRatio: devicePixelRatio,
      padding: EdgeInsets.fromViewPadding(view.padding, devicePixelRatio),
      viewPadding: EdgeInsets.fromViewPadding(view.viewPadding, devicePixelRatio),
      viewInsets: EdgeInsets.fromViewPadding(view.viewInsets, devicePixelRatio),
      systemGestureInsets: EdgeInsets.fromViewPadding(view.systemGestureInsets, devicePixelRatio),
      // TODO 需要验证对不对
      displayFeatures: view.displayFeatures
          .map<DisplayFeature>(
            (e) => DisplayFeature(
              bounds: Rect.fromLTRB(
                view.devicePixelRatio * e.bounds.left / devicePixelRatio,
                view.devicePixelRatio * e.bounds.top / devicePixelRatio,
                view.devicePixelRatio * e.bounds.right / devicePixelRatio,
                view.devicePixelRatio * e.bounds.bottom / devicePixelRatio,
              ),
              type: e.type,
              state: e.state,
            ),
          )
          .toList(growable: false),
    );
  }
}
