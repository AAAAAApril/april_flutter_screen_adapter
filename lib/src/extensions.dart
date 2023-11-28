import 'dart:ui';

import 'package:flutter/widgets.dart';

extension SizeExt on Size {
  double devicePixelRatioByWidth(double designWidth) {
    return width / designWidth;
  }
}

extension BuildContextExt on BuildContext {
  MediaQueryData adaptMediaQueryDataByDesignWidth(double designWidth) {
    final FlutterView view = View.of(this);
    final double devicePixelRatio = view.physicalSize.devicePixelRatioByWidth(designWidth);
    final MediaQueryData data = MediaQuery.of(this);
    if (data.devicePixelRatio == devicePixelRatio) {
      return data;
    }
    return data.copyWith(
      size: view.physicalSize / devicePixelRatio,
      devicePixelRatio: devicePixelRatio,
      padding: EdgeInsets.fromViewPadding(view.padding, devicePixelRatio),
      viewPadding: EdgeInsets.fromViewPadding(view.viewPadding, devicePixelRatio),
      viewInsets: EdgeInsets.fromViewPadding(view.viewInsets, devicePixelRatio),
      systemGestureInsets: EdgeInsets.fromViewPadding(view.systemGestureInsets, devicePixelRatio),
      displayFeatures: view.transformDisplayFeature(devicePixelRatio),
    );
  }
}

extension on FlutterView {
  List<DisplayFeature> transformDisplayFeature(double anotherDevicePixelRatio) {
    return displayFeatures
        .map<DisplayFeature>(
          (e) => DisplayFeature(
            bounds: Rect.fromLTRB(
              devicePixelRatio * e.bounds.left / anotherDevicePixelRatio,
              devicePixelRatio * e.bounds.top / anotherDevicePixelRatio,
              devicePixelRatio * e.bounds.right / anotherDevicePixelRatio,
              devicePixelRatio * e.bounds.bottom / anotherDevicePixelRatio,
            ),
            type: e.type,
            state: e.state,
          ),
        )
        .toList(growable: false);
  }
}
