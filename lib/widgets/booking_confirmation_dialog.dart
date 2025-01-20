import 'package:flutter/material.dart';
import 'package:lrts/models/station.dart';
import 'package:lottie/lottie.dart';

class BookingConfirmationDialog extends StatelessWidget {
  final Station station;
  final String estimatedTime;
  final String driverName;
  final String vehicleNumber;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const BookingConfirmationDialog({
    super.key,
    required this.station,
    required this.estimatedTime,
    required this.driverName,
    required this.vehicleNumber,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/animations/auto_confirmation.json',
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 16),
            Text(
              'Confirm Your Ride',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Destination', station.name),
            _buildInfoRow('Estimated Time', estimatedTime),
            _buildInfoRow('Driver', driverName),
            _buildInfoRow('Vehicle', vehicleNumber),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    child: const Text('Confirm'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
} 