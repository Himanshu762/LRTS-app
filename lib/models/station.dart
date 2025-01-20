enum Demand {
  high,
  medium,
  low,
}

class Station {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String zone;
  final int rickshaws;
  final Demand demand;
  final int waitTime;
  final int landmarks;

  const Station({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.zone,
    required this.rickshaws,
    required this.demand,
    required this.waitTime,
    required this.landmarks,
  });
}

final List<Station> stations = [
  Station(
    id: 'Rajiv Chowk',
    name: 'Rajiv Chowk',
    latitude: 28.6327,
    longitude: 77.2195,
    zone: 'Central',
    rickshaws: 25,
    demand: Demand.high,
    waitTime: 3,
    landmarks: 12,
  ),
  Station(
    id: 'Kashmere Gate',
    name: 'Kashmere Gate',
    latitude: 28.6675,
    longitude: 77.2285,
    zone: 'North',
    rickshaws: 20,
    demand: Demand.high,
    waitTime: 4,
    landmarks: 8,
  ),
  Station(
    id: 'Central Secretariat',
    name: 'Central Secretariat',
    latitude: 28.6147,
    longitude: 77.2119,
    zone: 'Central',
    rickshaws: 15,
    demand: Demand.medium,
    waitTime: 2,
    landmarks: 10,
  ),
  Station(
    id: 'Dwarka Sector 21',
    name: 'Dwarka Sector 21',
    latitude: 28.5520,
    longitude: 77.0587,
    zone: 'West',
    rickshaws: 12,
    demand: Demand.low,
    waitTime: 1,
    landmarks: 6,
  ),
  Station(
    id: 'Hauz Khas',
    name: 'Hauz Khas',
    latitude: 28.5430,
    longitude: 77.2060,
    zone: 'South',
    rickshaws: 18,
    demand: Demand.high,
    waitTime: 5,
    landmarks: 9,
  ),
  Station(
    id: 'Huda City Centre',
    name: 'Huda City Centre',
    latitude: 28.4594,
    longitude: 77.0720,
    zone: 'South',
    rickshaws: 22,
    demand: Demand.high,
    waitTime: 4,
    landmarks: 11,
  ),
  Station(
    id: 'Noida City Centre',
    name: 'Noida City Centre',
    latitude: 28.5747,
    longitude: 77.3560,
    zone: 'East',
    rickshaws: 16,
    demand: Demand.medium,
    waitTime: 3,
    landmarks: 7,
  ),
  Station(
    id: 'Chandni Chowk',
    name: 'Chandni Chowk',
    latitude: 28.6581,
    longitude: 77.2280,
    zone: 'North',
    rickshaws: 20,
    demand: Demand.high,
    waitTime: 4,
    landmarks: 15,
  ),
  Station(
    id: 'Lajpat Nagar',
    name: 'Lajpat Nagar',
    latitude: 28.5710,
    longitude: 77.2370,
    zone: 'South',
    rickshaws: 14,
    demand: Demand.medium,
    waitTime: 2,
    landmarks: 8,
  ),
  Station(
    id: 'Botanical Garden',
    name: 'Botanical Garden',
    latitude: 28.5644,
    longitude: 77.3347,
    zone: 'East',
    rickshaws: 15,
    demand: Demand.low,
    waitTime: 2,
    landmarks: 6,
  ),
  Station(
    id: 'Vaishali',
    name: 'Vaishali',
    latitude: 28.6458,
    longitude: 77.3399,
    zone: 'East',
    rickshaws: 12,
    demand: Demand.medium,
    waitTime: 3,
    landmarks: 5,
  ),
  Station(
    id: 'Janakpuri West',
    name: 'Janakpuri West',
    latitude: 28.6289,
    longitude: 77.0780,
    zone: 'West',
    rickshaws: 10,
    demand: Demand.low,
    waitTime: 1,
    landmarks: 7,
  ),
];
