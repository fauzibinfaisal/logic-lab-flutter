import 'package:web/web.dart' as web;

Future<bool> downloadCv() async {
  try {
    web.HTMLAnchorElement()
      ..href = 'assets/output/pdf/Fauzi-CV.pdf'
      ..download = 'Fauzi-CV.pdf'
      ..click();
    return true;
  } catch (_) {
    return false;
  }
}
