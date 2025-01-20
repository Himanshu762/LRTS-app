import 'package:flutter/material.dart';
import 'package:lrts/models/station.dart';
import 'package:lrts/widgets/booking_confirmation_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lrts/widgets/ride_tracking_overlay.dart';

class StationInfoSheet extends StatelessWidget {
  final Station station;

  const StationInfoSheet({
    super.key,
    required this.station,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            station.name,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          _buildDemandIndicator(context),
          const SizedBox(height: 8),
          _buildInfoRow('Zone', station.zone),
          _buildInfoRow('Available Rickshaws', '${station.rickshaws}'),
          _buildInfoRow('Current Demand', station.demand.toString()),
          _buildInfoRow('Wait Time', '${station.waitTime} mins'),
          _buildInfoRow('Nearby Landmarks', '${station.landmarks}'),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _handleBooking(context),
              child: const Text('Book a Ride'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDemandIndicator(BuildContext context) {
    final Color color;
    final IconData icon;

    switch (station.demand) {
      case Demand.high:
        color = Colors.red;
        icon = Icons.warning;
        break;
      case Demand.medium:
        color = Colors.orange;
        icon = Icons.info;
        break;
      default:
        color = Colors.green;
        icon = Icons.check_circle;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            '${station.demand} Demand',
            style: TextStyle(color: color, fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _handleBooking(BuildContext context) async {
    Navigator.pop(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => BookingConfirmationDialog(
        station: station,
        estimatedTime: '${station.waitTime} mins',
        driverName: 'Rajesh Kumar', // In real app, get from backend
        vehicleNumber: 'DL 1RT 1234', // In real app, get from backend
        onConfirm: () async {
          Navigator.pop(context, true);
          try {
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              await Supabase.instance.client.from('bookings').insert({
                'user_id': user.uid,
                'station_id': station.id,
                'driver_name': 'Rajesh Kumar',
                'vehicle_number': 'DL 1RT 1234',
                'status': 'confirmed',
                'estimated_time': station.waitTime,
                'booked_at': DateTime.now().toIso8601String(),
              });
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Booking confirmed!')),
              );
            }
          } catch (e) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to confirm booking')),
            );
          }
        },
        onCancel: () => Navigator.pop(context, false),
      ),
    );

    if (result == true) {
      if (!context.mounted) return;
      showModalBottomSheet(
        context: context,
        isDismissible: false,
        enableDrag: false,
        builder: (context) => RideTrackingOverlay(
          destination: station,
          driverName: 'Rajesh Kumar',
          vehicleNumber: 'DL 1RT 1234',
          estimatedTime: '${station.waitTime} mins',
          progress: 0.0,
          onCancel: () => Navigator.pop(context),
        ),
      );
    }
  }
}
