import 'dart:async';
import 'dart:collection';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class ScreenAdapterWidgetsFlutterBinding extends WidgetsFlutterBinding {
  static void runApp(
    Widget app, {
    required double designWidth,
  }) {
    _designWidth = designWidth;
    final ScreenAdapterWidgetsFlutterBinding adapter = ScreenAdapterWidgetsFlutterBinding.ensureInitialized();
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
    final double devicePixelRatio =
        (view.physicalSize.width < view.physicalSize.height ? view.physicalSize.width : view.physicalSize.height) /
            _designWidth;
    return MediaQuery(
      data: maybeData.copyWith(
        size: view.physicalSize / devicePixelRatio,
        devicePixelRatio: devicePixelRatio,
        textScaleFactor: textScaleFactor,
        padding: EdgeInsets.fromViewPadding(view.padding, devicePixelRatio),
        viewPadding: EdgeInsets.fromViewPadding(view.viewPadding, devicePixelRatio),
        viewInsets: EdgeInsets.fromViewPadding(view.viewInsets, devicePixelRatio),
        systemGestureInsets: EdgeInsets.fromViewPadding(view.systemGestureInsets, devicePixelRatio),
        displayFeatures: _decodeDisplayFeatures(
          displayFeature: view.displayFeatures,
          bounds: displayFeaturesBounds,
          type: displayFeaturesType,
          state: displayFeaturesState,
          devicePixelRatio: devicePixelRatio,
          realDevicePixelRatio: view.devicePixelRatio,
        ),
      ),
      child: child,
    );
  }

  static ScreenAdapterWidgetsFlutterBinding ensureInitialized() {
    if (_instance == null) {
      ScreenAdapterWidgetsFlutterBinding._();
    }
    return WidgetsBinding.instance as ScreenAdapterWidgetsFlutterBinding;
  }

  /// TODO 把用真实 [devicePixelRatio] 计算过的 [DisplayFeature] 转换为目标 [devicePixelRatio] 计算后的值
  static List<DisplayFeature> _decodeDisplayFeatures({
    required List<DisplayFeature> displayFeature,
    required List<double> bounds,
    required List<int> type,
    required List<int> state,
    required double devicePixelRatio,
    required double realDevicePixelRatio,
  }) {
    assert(bounds.length / 4 == type.length, 'Bounds are rectangles, requiring 4 measurements each');
    assert(type.length == state.length);
    final List<DisplayFeature> result = <DisplayFeature>[];
    for (int i = 0; i < type.length; i++) {
      final int rectOffset = i * 4;
      result.add(DisplayFeature(
        bounds: Rect.fromLTRB(
          bounds[rectOffset] / devicePixelRatio,
          bounds[rectOffset + 1] / devicePixelRatio,
          bounds[rectOffset + 2] / devicePixelRatio,
          bounds[rectOffset + 3] / devicePixelRatio,
        ),
        type: DisplayFeatureType.values[type[i]],
        state: state[i] < DisplayFeatureState.values.length
            ? DisplayFeatureState.values[state[i]]
            : DisplayFeatureState.unknown,
      ));
    }
    return result;
  }

  static ScreenAdapterWidgetsFlutterBinding? _instance;

  ScreenAdapterWidgetsFlutterBinding._() {
    _instance = this;
  }

  ///设计稿宽度
  static double _designWidth = 375;

  @override
  void initInstances() {
    super.initInstances();
    debugPrint('>>>April<<<.[initInstances]');
    platformDispatcher.onPointerDataPacket = _handlePointerDataPacket;
  }

  @override
  ViewConfiguration createViewConfiguration() {
    debugPrint('>>>April<<<.[createViewConfiguration]');
    // final FlutterView view = platformDispatcher.implicitView!;
    // final double devicePixelRatio = view.devicePixelRatio;
    // return ViewConfiguration(
    //   size: view.physicalSize / devicePixelRatio,
    //   devicePixelRatio: devicePixelRatio,
    // );
    final ui.FlutterView view = platformDispatcher.implicitView!;
    final double devicePixelRatio =
        (view.physicalSize.width < view.physicalSize.height ? view.physicalSize.width : view.physicalSize.height) /
            _designWidth;
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
    debugPrint('>>>April<<<.[unlocked]');
    _flushPointerEventQueue();
  }

  void _handlePointerDataPacket(ui.PointerDataPacket packet) {
    try {
      debugPrint('>>>April<<<.[_handlePointerDataPacket.try]');
      final ui.FlutterView view = platformDispatcher.implicitView!;
      _pendingPointerEvents.addAll(
        PointerEventConverter.expand(
          packet.data,
          (view.physicalSize.width < view.physicalSize.height ? view.physicalSize.width : view.physicalSize.height) /
              _designWidth,
        ),
      );
      if (!locked) {
        debugPrint('>>>April<<<.[_handlePointerDataPacket.!locked]');
        _flushPointerEventQueue();
      }
    } catch (error, stack) {
      debugPrint('>>>April<<<.[_handlePointerDataPacket.catch]');
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
    debugPrint('>>>April<<<.[cancelPointer]');
    if (_pendingPointerEvents.isEmpty && !locked) {
      scheduleMicrotask(_flushPointerEventQueue);
    }
    _pendingPointerEvents.addFirst(PointerCancelEvent(pointer: pointer));
  }

  void _flushPointerEventQueue() {
    debugPrint('>>>April<<<.[_flushPointerEventQueue]');
    assert(!locked);

    while (_pendingPointerEvents.isNotEmpty) {
      debugPrint('>>>April<<<.[_flushPointerEventQueue.while]');
      handlePointerEvent(_pendingPointerEvents.removeFirst());
    }
  }
}
