import 'package:april_flutter_screen_adapter/src/extensions.dart';
import 'package:flutter/widgets.dart';

import 'bindings/widgets_flutter_binding.dart';

class ScreenAdapter {
  static WidgetsBinding ensureInitialized({
    required double designWidth,
  }) {
    _designWidth = designWidth;
    return ScreenAdapterWidgetsFlutterBinding.ensureInitialized();
  }

  ///设计稿宽度
  static late final double _designWidth;

  static double get designWidth => _designWidth;

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
    return context.adaptMediaQueryDataByDesignWidth(designWidth);
  }

  ScreenAdapter._();
}
