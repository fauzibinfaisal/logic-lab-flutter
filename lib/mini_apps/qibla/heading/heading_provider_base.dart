abstract class HeadingProvider {
  Stream<double> get headings;

  Future<bool> start();

  void dispose();
}
