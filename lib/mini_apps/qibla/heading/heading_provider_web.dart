import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:logic_lab/mini_apps/qibla/heading/heading_provider_base.dart';
import 'package:web/web.dart' as web;

@JS('DeviceOrientationEvent')
external JSObject? get _deviceOrientationEvent;

HeadingProvider createPlatformHeadingProvider() => _WebHeadingProvider();

class _WebHeadingProvider implements HeadingProvider {
  final _controller = StreamController<double>.broadcast();
  web.EventListener? _listener;

  @override
  Stream<double> get headings => _controller.stream;

  @override
  Future<bool> start() async {
    if (_listener != null) return true;

    try {
      final constructor = _deviceOrientationEvent;
      if (constructor != null && constructor.has('requestPermission')) {
        final promise = constructor.callMethod<JSPromise<JSString>>(
          'requestPermission'.toJS,
        );
        final permission = (await promise.toDart).toDart;
        if (permission != 'granted') {
          return false;
        }
      }

      _listener = ((web.Event rawEvent) {
        final event = rawEvent as web.DeviceOrientationEvent;
        double? heading;

        if (event.has('webkitCompassHeading')) {
          final value = event['webkitCompassHeading'];
          if (value != null && value.isA<JSNumber>()) {
            heading = (value as JSNumber).toDartDouble;
          }
        } else if (event.absolute && event.alpha != null) {
          heading = (360 - event.alpha!) % 360;
        }

        if (heading != null && heading.isFinite) {
          _controller.add(heading);
        }
      }).toJS;
      web.window.addEventListener('deviceorientation', _listener);
      web.window.addEventListener('deviceorientationabsolute', _listener);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    web.window.removeEventListener('deviceorientation', _listener);
    web.window.removeEventListener('deviceorientationabsolute', _listener);
    _controller.close();
  }
}
