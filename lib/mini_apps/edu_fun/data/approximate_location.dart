import 'dart:math' as math;

import 'package:geolocator/geolocator.dart';

class ApproximateLocation {
  const ApproximateLocation._();

  static const _cities = [
    ('Jakarta', -6.2088, 106.8456),
    ('Bandung', -6.9175, 107.6191),
    ('Surabaya', -7.2575, 112.7521),
    ('Yogyakarta', -7.7956, 110.3695),
    ('Semarang', -6.9667, 110.4167),
    ('Medan', 3.5952, 98.6722),
    ('Makassar', -5.1477, 119.4327),
    ('Denpasar', -8.6705, 115.2126),
    ('Palembang', -2.9909, 104.7566),
  ];

  static Future<String?> detectCity() async {
    if (!await Geolocator.isLocationServiceEnabled()) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
        timeLimit: Duration(seconds: 10),
      ),
    );

    var nearest = _cities.first;
    var nearestDistance = double.infinity;
    for (final city in _cities) {
      final distance = _distanceKm(
        position.latitude,
        position.longitude,
        city.$2,
        city.$3,
      );
      if (distance < nearestDistance) {
        nearest = city;
        nearestDistance = distance;
      }
    }

    return nearestDistance <= 350 ? '${nearest.$1}, Indonesia' : 'Other region';
  }

  static double _distanceKm(
    double latitudeA,
    double longitudeA,
    double latitudeB,
    double longitudeB,
  ) {
    const earthRadius = 6371.0;
    final latitudeDelta = _radians(latitudeB - latitudeA);
    final longitudeDelta = _radians(longitudeB - longitudeA);
    final value = math.sin(latitudeDelta / 2) * math.sin(latitudeDelta / 2) +
        math.cos(_radians(latitudeA)) *
            math.cos(_radians(latitudeB)) *
            math.sin(longitudeDelta / 2) *
            math.sin(longitudeDelta / 2);
    return earthRadius * 2 * math.atan2(math.sqrt(value), math.sqrt(1 - value));
  }

  static double _radians(double degrees) => degrees * math.pi / 180;
}
