import 'dart:async';
import 'dart:collection';
import 'dart:ui';

import 'package:april_flutter_screen_adapter/src/extensions.dart';
import 'package:april_flutter_screen_adapter/src/screen_adapter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

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

  void _handlePointerDataPacket(PointerDataPacket packet) {
    try {
      final FlutterView view = platformDispatcher.implicitView!;
      _pendingPointerEvents.addAll(
        PointerEventConverter.expand(
          packet.data,
          view.physicalSize.devicePixelRatioByWidth(
            ScreenAdapter.designWidth,
          ),
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
