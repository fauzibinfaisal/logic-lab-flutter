import 'dart:math' as math;

class QiblaCalculator {
  static const kaabaLatitude = 21.4225;
  static const kaabaLongitude = 39.8262;

  const QiblaCalculator._();

  static double bearingFrom(double latitude, double longitude) {
    final latitudeRadians = _toRadians(latitude);
    final kaabaLatitudeRadians = _toRadians(kaabaLatitude);
    final longitudeDelta = _toRadians(kaabaLongitude - longitude);

    final y = math.sin(longitudeDelta);
    final x = math.cos(latitudeRadians) * math.tan(kaabaLatitudeRadians) -
        math.sin(latitudeRadians) * math.cos(longitudeDelta);

    return (_toDegrees(math.atan2(y, x)) + 360) % 360;
  }

  static double relativeDirection({
    required double qiblaBearing,
    required double heading,
  }) =>
      (qiblaBearing - heading + 360) % 360;

  static String cardinalDirection(double bearing) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = ((bearing + 22.5) ~/ 45) % directions.length;
    return directions[index];
  }

  static double _toRadians(double degrees) => degrees * math.pi / 180;
  static double _toDegrees(double radians) => radians * 180 / math.pi;
}
