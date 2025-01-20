import 'package:lrts/models/station.dart';

enum RideStatus {
  completed,
  cancelled,
  inprogress,
}

class RideHistory {
  final String id;
  final Station destination;
  final DateTime timestamp;
  final RideStatus status;

  const RideHistory({
    required this.id,
    required this.destination,
    required this.timestamp,
    required this.status,
  });
} 