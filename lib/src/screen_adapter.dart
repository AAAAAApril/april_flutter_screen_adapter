import 'package:april_flutter_screen_adapter/src/extensions.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'widgets_flutter_binding.dart';

typedef DesignWidthCreator = double Function(RendererBinding binding, FlutterView view);

class ScreenAdapter {
  static WidgetsBinding ensureInitialized({
    required DesignWidthCreator designWidth,
  }) {
    _designWidthCreator = designWidth;
    return ScreenAdapterWidgetsFlutterBinding.ensureInitialized();
  }

  ///返回每个 [FlutterView] 对应的设计稿宽度
  static late final DesignWidthCreator _designWidthCreator;

  static DesignWidthCreator get designWidthCreator => _designWidthCreator;

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
        textScaler: textScaleFactor == null ? null : TextScaler.linear(textScaleFactor),
      ),
      child: child,
    );
  }

  static MediaQueryData compatMediaQueryData(BuildContext context) {
    final FlutterView view = View.of(context);
    return context.adaptMediaQueryDataByDesignWidth(designWidthCreator.call(WidgetsBinding.instance, view));
  }

  ScreenAdapter._();
}
