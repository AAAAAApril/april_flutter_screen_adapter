import 'dart:async';
import 'dart:collection';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class ScreenAdapterWidgetsFlutterBinding extends WidgetsFlutterBinding {
  static void runApp(
    Widget app, {
    required double designWidth,
  }) {
    final ScreenAdapterWidgetsFlutterBinding adapter = ScreenAdapterWidgetsFlutterBinding.ensureInitialized(
      designWidth: designWidth,
    );
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
    final ui.FlutterView view = ui.PlatformDispatcher.instance.implicitView!;
    final double devicePixelRatio = view.physicalSize.width / ScreenAdapterWidgetsFlutterBinding._instance!.designWidth;
    return MediaQuery(
      data: maybeData.copyWith(
        size: view.physicalSize / devicePixelRatio,
        devicePixelRatio: devicePixelRatio,
        textScaleFactor: textScaleFactor,
      ),
      child: child,
    );
  }

  static ScreenAdapterWidgetsFlutterBinding ensureInitialized({required double designWidth}) {
    if (_instance == null) {
      ScreenAdapterWidgetsFlutterBinding._(
        designWidth: designWidth,
      );
    }
    return WidgetsBinding.instance as ScreenAdapterWidgetsFlutterBinding;
  }

  static ScreenAdapterWidgetsFlutterBinding? _instance;

  ScreenAdapterWidgetsFlutterBinding._({
    required this.designWidth,
  }) {
    _instance = this;
  }

  ///设计稿宽度
  final double designWidth;

  @override
  void initInstances() {
    super.initInstances();
    platformDispatcher.onPointerDataPacket = _handlePointerDataPacket;
  }

  @override
  ViewConfiguration createViewConfiguration() {
    // final FlutterView view = platformDispatcher.implicitView!;
    // final double devicePixelRatio = view.devicePixelRatio;
    // return ViewConfiguration(
    //   size: view.physicalSize / devicePixelRatio,
    //   devicePixelRatio: devicePixelRatio,
    // );
    final ui.FlutterView view = platformDispatcher.implicitView!;
    final double devicePixelRatio = view.physicalSize.width / designWidth;
    return ViewConfiguration(
      size: view.physicalSize / devicePixelRatio,
      devicePixelRatio: devicePixelRatio,
    );
  }

  //====================================

  final Queue<PointerEvent> _pendingPointerEvents = Queue<PointerEvent>();

  @override
  void unlocked() {
    super.unlocked();
    _flushPointerEventQueue();
  }

  void _handlePointerDataPacket(ui.PointerDataPacket packet) {
    try {
      _pendingPointerEvents.addAll(
        PointerEventConverter.expand(
          packet.data,
          ui.PlatformDispatcher.instance.implicitView!.physicalSize.width /
              ScreenAdapterWidgetsFlutterBinding._instance!.designWidth,
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
