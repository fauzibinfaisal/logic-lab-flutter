import 'package:logic_lab/mini_apps/qibla/heading/heading_provider_base.dart';

HeadingProvider createPlatformHeadingProvider() =>
    _UnsupportedHeadingProvider();

class _UnsupportedHeadingProvider implements HeadingProvider {
  @override
  Stream<double> get headings => const Stream.empty();

  @override
  Future<bool> start() async => false;

  @override
  void dispose() {}
}
