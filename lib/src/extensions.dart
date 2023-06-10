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
      // displayFeatures: _decodeDisplayFeatures(
      //   displayFeature: view.displayFeatures,
      //   bounds: displayFeaturesBounds,
      //   type: displayFeaturesType,
      //   state: displayFeaturesState,
      //   devicePixelRatio: devicePixelRatio,
      //   realDevicePixelRatio: view.devicePixelRatio,
      // ),
    );
  }
}

// /// TODO 把用真实 [devicePixelRatio] 计算过的 [DisplayFeature] 转换为目标 [devicePixelRatio] 计算后的值
// List<DisplayFeature> _decodeDisplayFeatures({
//   required List<DisplayFeature> displayFeature,
//   required List<double> bounds,
//   required List<int> type,
//   required List<int> state,
//   required double devicePixelRatio,
//   required double realDevicePixelRatio,
// }) {
//   assert(bounds.length / 4 == type.length, 'Bounds are rectangles, requiring 4 measurements each');
//   assert(type.length == state.length);
//   final List<DisplayFeature> result = <DisplayFeature>[];
//   for (int i = 0; i < type.length; i++) {
//     final int rectOffset = i * 4;
//     result.add(DisplayFeature(
//       bounds: Rect.fromLTRB(
//         bounds[rectOffset] / devicePixelRatio,
//         bounds[rectOffset + 1] / devicePixelRatio,
//         bounds[rectOffset + 2] / devicePixelRatio,
//         bounds[rectOffset + 3] / devicePixelRatio,
//       ),
//       type: DisplayFeatureType.values[type[i]],
//       state: state[i] < DisplayFeatureState.values.length
//           ? DisplayFeatureState.values[state[i]]
//           : DisplayFeatureState.unknown,
//     ));
//   }
//   return result;
// }
