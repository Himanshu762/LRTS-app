import 'package:flutter/material.dart';
import 'package:lrts/models/station.dart';
import 'package:lottie/lottie.dart';

class RideTrackingOverlay extends StatelessWidget {
  final Station destination;
  final String driverName;
  final String vehicleNumber;
  final String estimatedTime;
  final double progress;
  final VoidCallback onCancel;

  const RideTrackingOverlay({
    super.key,
    required this.destination,
    required this.driverName,
    required this.vehicleNumber,
    required this.estimatedTime,
    required this.progress,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  child: Lottie.asset(
                    'assets/animations/driver_avatar.json',
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(driverName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(vehicleNumber),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: onCancel,
                  icon: const Icon(Icons.phone),
                  label: const Text('Contact'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 8),
            Text(
              'Estimated arrival in $estimatedTime',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
} 