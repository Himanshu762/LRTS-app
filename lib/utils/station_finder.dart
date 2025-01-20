import 'package:lrts/models/station.dart';
import 'dart:math';

List<Station> findNearestStations(double lat, double lng, List<Station> stations) {
  return stations
    ..sort((a, b) {
      final distA = _calculateDistance(lat, lng, a.latitude, a.longitude);
      final distB = _calculateDistance(lat, lng, b.latitude, b.longitude);
      return distA.compareTo(distB);
    })
    ..take(5);
}

double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const R = 6371e3; // Earth's radius in meters
  final phi1 = lat1 * pi / 180;
  final phi2 = lat2 * pi / 180;
  final deltaPhi = (lat2 - lat1) * pi / 180;
  final deltaLambda = (lon2 - lon1) * pi / 180;

  final a = sin(deltaPhi / 2) * sin(deltaPhi / 2) +
      cos(phi1) * cos(phi2) * sin(deltaLambda / 2) * sin(deltaLambda / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return R * c;
} 