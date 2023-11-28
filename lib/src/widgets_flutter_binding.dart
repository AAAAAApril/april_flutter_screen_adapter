import 'dart:async';
import 'dart:collection';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'bindings/gesture_binding.dart';
import 'bindings/renderer_binding.dart';
import 'screen_adapter.dart';
import 'extensions.dart';

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

//======================================================================================================================

  @override
  ViewConfiguration createViewConfigurationFor(RenderView renderView) {
    final FlutterView view = renderView.flutterView;
    final double devicePixelRatio = view.physicalSize.devicePixelRatioByWidth(
      ScreenAdapter.designWidthCreator.call(this, view),
    );
    return ViewConfiguration(
      size: view.physicalSize / devicePixelRatio,
      devicePixelRatio: devicePixelRatio,
    );
  }

//======================================================================================================================

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

  final Queue<PointerEvent> _pendingPointerEvents = Queue<PointerEvent>();

  void _handlePointerDataPacket(PointerDataPacket packet) {
    try {
      _pendingPointerEvents.addAll(PointerEventConverter.expand(packet.data, _devicePixelRatioForView));
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

  double? _devicePixelRatioForView(int viewId) {
    try {
      return platformDispatcher.view(id: viewId)?.physicalSize.devicePixelRatioByWidth(
            ScreenAdapter.designWidthCreator.call(
              this,
              renderViews.firstWhere((element) => element.flutterView.viewId == viewId).flutterView,
            ),
          );
    } catch (_) {
      return null;
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
