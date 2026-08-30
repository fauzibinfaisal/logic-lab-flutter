import 'package:logic_lab/mini_apps/qibla/heading/heading_provider_base.dart';
import 'package:logic_lab/mini_apps/qibla/heading/heading_provider_stub.dart'
    if (dart.library.html) 'package:logic_lab/mini_apps/qibla/heading/heading_provider_web.dart';

export 'package:logic_lab/mini_apps/qibla/heading/heading_provider_base.dart';

HeadingProvider createHeadingProvider() => createPlatformHeadingProvider();
