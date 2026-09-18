import 'package:url_launcher/url_launcher.dart';

abstract final class PortfolioLinks {
  static final email = Uri(
    scheme: 'mailto',
    path: 'fauzibinfaisal@gmail.com',
    queryParameters: {
      'subject': 'Hello Fauzi - Mobile Engineering Opportunity',
    },
  );

  static final phone = Uri(
    scheme: 'tel',
    path: '+6285890406101',
  );

  static final location = Uri.https(
    'www.google.com',
    '/maps/search/',
    {'api': '1', 'query': 'Jakarta, Indonesia'},
  );

  static final github = Uri.parse('https://github.com/fauzibinfaisal');
  static final linkedin = Uri.parse(
    'https://www.linkedin.com/in/fauzibinfaisal',
  );
  static final cv = Uri.parse(
    'https://fauzibinfaisal.github.io/assets/output/pdf/Fauzi-CV.pdf',
  );

  static Future<bool> open(Uri uri) async {
    try {
      return await launchUrl(
        uri,
        mode: uri.scheme == 'http' || uri.scheme == 'https'
            ? LaunchMode.externalApplication
            : LaunchMode.platformDefault,
        webOnlyWindowName:
            uri.scheme == 'http' || uri.scheme == 'https' ? '_blank' : null,
      );
    } catch (_) {
      return false;
    }
  }
}
