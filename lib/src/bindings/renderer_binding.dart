import 'dart:ui';

import 'package:april_flutter_screen_adapter/src/extensions.dart';
import 'package:april_flutter_screen_adapter/src/screen_adapter.dart';
import 'package:flutter/rendering.dart';

mixin ScreenAdapterRendererBinding on RendererBinding {
  @override
  ViewConfiguration createViewConfiguration() {
    final FlutterView view = platformDispatcher.implicitView!;
    final double devicePixelRatio = view.physicalSize.devicePixelRatioByWidth(
      ScreenAdapter.designWidth,
    );
    return ViewConfiguration(
      size: view.physicalSize / devicePixelRatio,
      devicePixelRatio: devicePixelRatio,
    );
  }
}
