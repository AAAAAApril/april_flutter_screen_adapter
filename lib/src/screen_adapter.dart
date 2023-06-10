import 'package:flutter/widgets.dart';

import 'screen_adapter_widgets_flutter_binding.dart';

class ScreenAdapter {
  static WidgetsBinding ensureInitialized({
    required double designWidth,
  }) =>
      ScreenAdapterWidgetsFlutterBinding.ensureInitialized(
        designWidth: designWidth,
      );

  static WidgetsBinding get instance => ScreenAdapterWidgetsFlutterBinding.instance;

  static void runApp(
    Widget app, {
    double? designWidth,
  }) =>
      ScreenAdapterWidgetsFlutterBinding.runApp(
        app,
        designWidth: designWidth,
      );

  static Widget compatBuilder(
    BuildContext context,
    Widget? child, {
    double? textScaleFactor = 1,
  }) =>
      ScreenAdapterWidgetsFlutterBinding.compatMediaQuery(
        context,
        child ?? const SizedBox.shrink(),
        textScaleFactor: textScaleFactor,
      );

  ScreenAdapter._();
}
