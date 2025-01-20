import 'package:flutter/material.dart';
import 'package:lrts/models/pass.dart';
import 'package:lrts/models/station.dart';

class ZoneSelectionScreen extends StatefulWidget {
  final Pass pass;
  final Function(Map<String, dynamic>) onPassPurchased;

  const ZoneSelectionScreen({
    super.key,
    required this.pass,
    required this.onPassPurchased,
  });

  @override
  State<ZoneSelectionScreen> createState() => _ZoneSelectionScreenState();
}

class _ZoneSelectionScreenState extends State<ZoneSelectionScreen> {
  String? _selectedHomeZone;
  String? _selectedDestinationZone;

  // Extract unique zones from stations
  List<String> get _zones {
    return stations.map((station) => station.zone).toSet().toList();
  }

  // Determine if the pass is dual zone
  bool get _isDualZone {
    return widget.pass.title.toLowerCase().contains('dual zone');
  }

  void _submitSelection() {
    if (_selectedHomeZone == null ||
        (_isDualZone && _selectedDestinationZone == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select all required zones.')),
      );
      return;
    }

    // Proceed with the selected zones
    // You can navigate to the next screen or perform further actions here
    // For example:
    Navigator.pop(context, {
      'homeZone': _selectedHomeZone,
      if (_isDualZone) 'destinationZone': _selectedDestinationZone,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Zone for ${widget.pass.title}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Select Home Zone',
                border: OutlineInputBorder(),
              ),
              items: _zones.map((zone) {
                return DropdownMenuItem(
                  value: zone,
                  child: Text(zone),
                );
              }).toList(),
              value: _selectedHomeZone,
              onChanged: (value) {
                setState(() {
                  _selectedHomeZone = value;
                });
              },
              validator: (value) =>
                  value == null ? 'Please select a home zone' : null,
            ),
            const SizedBox(height: 16),
            if (_isDualZone)
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select Destination Zone',
                  border: OutlineInputBorder(),
                ),
                items: _zones.map((zone) {
                  return DropdownMenuItem(
                    value: zone,
                    child: Text(zone),
                  );
                }).toList(),
                value: _selectedDestinationZone,
                onChanged: (value) {
                  setState(() {
                    _selectedDestinationZone = value;
                  });
                },
                validator: (value) => value == null
                    ? 'Please select a destination zone'
                    : null,
              ),
            const Spacer(),
            ElevatedButton(
              onPressed: _submitSelection,
              child: const Text('Confirm Selection'),
            ),
          ],
        ),
      ),
    );
  }
} 