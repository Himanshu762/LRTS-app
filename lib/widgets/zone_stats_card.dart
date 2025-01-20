import 'package:flutter/material.dart';
import 'package:lrts/models/station.dart';

class ZoneStatsCard extends StatelessWidget {
  final String zoneName;
  final List<Station> stations;

  const ZoneStatsCard({
    super.key,
    required this.zoneName,
    required this.stations,
  });

  @override
  Widget build(BuildContext context) {
    final zoneStations = stations.where((s) => s.zone == zoneName).toList();
    final totalRickshaws = zoneStations.fold<int>(0, (sum, s) => sum + s.rickshaws);
    final avgWaitTime = zoneStations.fold<int>(0, (sum, s) => sum + s.waitTime) / zoneStations.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$zoneName Zone',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            _buildStatRow('Stations', '${zoneStations.length}'),
            _buildStatRow('Total Rickshaws', '$totalRickshaws'),
            _buildStatRow('Avg. Wait Time', '${avgWaitTime.toStringAsFixed(1)} mins'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
} 