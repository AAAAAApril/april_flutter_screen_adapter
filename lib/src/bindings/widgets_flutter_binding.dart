import 'package:flutter/widgets.dart';

import 'gesture_binding.dart';
import 'renderer_binding.dart';

class ScreenAdapterWidgetsFlutterBinding extends WidgetsFlutterBinding
    with ScreenAdapterGestureBinding, ScreenAdapterRendererBinding {
  static WidgetsBinding ensureInitialized() {
    if (_instance == null) {
      ScreenAdapterWidgetsFlutterBinding._();
    }
    return WidgetsBinding.instance;
  }

  static ScreenAdapterWidgetsFlutterBinding? _instance;

  ScreenAdapterWidgetsFlutterBinding._() : super() {
    _instance = this;
  }
}
