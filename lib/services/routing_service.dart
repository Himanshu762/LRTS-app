import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:latlong2/latlong.dart';

class RoutingService {
  static const String _baseUrl = 'https://router.project-osrm.org/route/v1';

  static Future<List<LatLng>> getRoute(LatLng start, LatLng end) async {
    final url = '$_baseUrl/driving/${start.longitude},${start.latitude};'
        '${end.longitude},${end.latitude}?overview=full&geometries=geojson';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final coordinates = data['routes'][0]['geometry']['coordinates'] as List;
        
        return coordinates.map((coord) {
          final list = coord as List;
          // OSRM returns coordinates as [longitude, latitude]
          return LatLng(list[1].toDouble(), list[0].toDouble());
        }).toList();
      }
      throw Exception('Failed to fetch route');
    } catch (e) {
      throw Exception('Route calculation failed: $e');
    }
  }
} 