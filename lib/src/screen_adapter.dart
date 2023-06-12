import 'package:april_flutter_screen_adapter/src/extensions.dart';
import 'package:flutter/widgets.dart';

import 'screen_adapter_widgets_flutter_binding.dart';

class ScreenAdapter {
  static WidgetsBinding ensureInitialized({
    required double designWidth,
  }) =>
      ScreenAdapterWidgetsFlutterBinding.ensureInitialized(
        designWidth: designWidth,
      );

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
  }) {
    child ??= const SizedBox.shrink();
    final MediaQueryData? maybeData = MediaQuery.maybeOf(context);
    if (maybeData == null) {
      return child;
    }
    return MediaQuery(
      data: compatMediaQueryData(context).copyWith(
        textScaleFactor: textScaleFactor,
      ),
      child: child,
    );
  }

  static MediaQueryData compatMediaQueryData(BuildContext context) {
    return context.adaptMediaQueryDataByDesignWidth(ScreenAdapterWidgetsFlutterBinding.designWidth);
  }

  ScreenAdapter._();
}
