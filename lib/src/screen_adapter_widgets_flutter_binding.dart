import 'dart:async';
import 'dart:collection';
import 'dart:ui' as ui;

import 'package:april_flutter_screen_adapter/src/extensions.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class ScreenAdapterWidgetsFlutterBinding extends WidgetsFlutterBinding
    with ScreenAdapterGestureBinding, ScreenAdapterRendererBinding {
  ///设计稿宽度
  static double _designWidth = 375;

  static WidgetsBinding ensureInitialized({double? designWidth}) {
    if (_instance == null) {
      if (designWidth != null) {
        ScreenAdapterWidgetsFlutterBinding._designWidth = designWidth;
      }
      ScreenAdapterWidgetsFlutterBinding._();
    }
    return WidgetsBinding.instance as ScreenAdapterWidgetsFlutterBinding;
  }

  static void runApp(
    Widget app, {
    double? designWidth,
  }) {
    final WidgetsBinding adapter = ScreenAdapterWidgetsFlutterBinding.ensureInitialized(designWidth: designWidth);
    adapter
      ..scheduleAttachRootWidget(adapter.wrapWithDefaultView(app))
      ..scheduleWarmUpFrame();
  }

  static Widget compatMediaQuery(
    BuildContext context,
    Widget child, {
    double? textScaleFactor,
  }) {
    final MediaQueryData? maybeData = MediaQuery.maybeOf(context);
    if (maybeData == null) {
      return child;
    }
    return MediaQuery(
      data: context.adaptMediaQueryDataByDesignWidth(_designWidth),
      child: child,
    );
  }

  static ScreenAdapterWidgetsFlutterBinding? _instance;

  static WidgetsBinding get instance => _instance!;

  ScreenAdapterWidgetsFlutterBinding._() {
    _instance = this;
  }
}

mixin ScreenAdapterRendererBinding on RendererBinding {
  @override
  ViewConfiguration createViewConfiguration() {
    // final FlutterView view = platformDispatcher.implicitView!;
    // final double devicePixelRatio = view.devicePixelRatio;
    // return ViewConfiguration(
    //   size: view.physicalSize / devicePixelRatio,
    //   devicePixelRatio: devicePixelRatio,
    // );
    final ui.FlutterView view = platformDispatcher.implicitView!;
    final double devicePixelRatio = view.physicalSize.devicePixelRatioByWidth(
      ScreenAdapterWidgetsFlutterBinding._designWidth,
    );
    return ViewConfiguration(
      size: view.physicalSize / devicePixelRatio,
      devicePixelRatio: devicePixelRatio,
    );
  }
}

mixin ScreenAdapterGestureBinding on GestureBinding {
  final Queue<PointerEvent> _pendingPointerEvents = Queue<PointerEvent>();

  @override
  void initInstances() {
    super.initInstances();
    platformDispatcher.onPointerDataPacket = _handlePointerDataPacket;
  }

  @override
  void unlocked() {
    super.unlocked();
    _flushPointerEventQueue();
  }

  void _handlePointerDataPacket(ui.PointerDataPacket packet) {
    try {
      final ui.FlutterView view = platformDispatcher.implicitView!;
      _pendingPointerEvents.addAll(
        PointerEventConverter.expand(
          packet.data,
          view.physicalSize.devicePixelRatioByWidth(ScreenAdapterWidgetsFlutterBinding._designWidth),
        ),
      );
      if (!locked) {
        _flushPointerEventQueue();
      }
    } catch (error, stack) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stack,
        library: 'gestures library',
        context: ErrorDescription('while handling a pointer data packet'),
      ));
    }
  }

  @override
  void cancelPointer(int pointer) {
    if (_pendingPointerEvents.isEmpty && !locked) {
      scheduleMicrotask(_flushPointerEventQueue);
    }
    _pendingPointerEvents.addFirst(PointerCancelEvent(pointer: pointer));
  }

  void _flushPointerEventQueue() {
    assert(!locked);

    while (_pendingPointerEvents.isNotEmpty) {
      handlePointerEvent(_pendingPointerEvents.removeFirst());
    }
  }
}
