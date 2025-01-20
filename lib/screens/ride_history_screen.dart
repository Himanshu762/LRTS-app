import 'package:flutter/material.dart';
import 'package:lrts/models/ride_history.dart';
import 'package:intl/intl.dart';

class RideHistoryScreen extends StatelessWidget {
  final List<RideHistory> rides;

  const RideHistoryScreen({
    super.key,
    required this.rides,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ride History')),
      body: ListView.builder(
        itemCount: rides.length,
        itemBuilder: (context, index) {
          final ride = rides[index];
          return ListTile(
            leading: Icon(
              ride.status == RideStatus.completed
                  ? Icons.check_circle
                  : ride.status == RideStatus.cancelled
                      ? Icons.cancel
                      : Icons.directions_car,
              color: _getStatusColor(ride.status),
            ),
            title: Text(ride.destination.name),
            subtitle: Text(
              '${DateFormat.yMMMd().format(ride.timestamp)}}',
            ),
            trailing: Text(ride.status.toString().split('.').last),
          );
        },
      ),
    );
  }

  Color _getStatusColor(RideStatus status) {
    switch (status) {
      case RideStatus.completed:
        return Colors.green;
      case RideStatus.cancelled:
        return Colors.red;
      case RideStatus.inprogress:
        return Colors.blue;
    }
  }
} 