import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lrts/widgets/station_search.dart';
import 'package:lrts/models/station.dart';
import 'package:lrts/widgets/booking_confirmation_dialog.dart';
import 'package:lrts/widgets/ride_tracking_overlay.dart';
import 'dart:async';
import 'package:lrts/models/ride_history.dart';
import 'package:lrts/services/notification_service.dart';
import 'package:uuid/uuid.dart';
import 'package:lrts/services/routing_service.dart';
import 'package:lrts/utils/station_finder.dart';

class TripPlannerScreen extends StatefulWidget {
  final List<Map<String, dynamic>> userPasses;
  
  const TripPlannerScreen({
    super.key,
    required this.userPasses,
  });

  @override
  State<TripPlannerScreen> createState() => _TripPlannerScreenState();
}

class _TripPlannerScreenState extends State<TripPlannerScreen> {
  final mapController = MapController();
  Position? _currentPosition;
  Station? _selectedStation;
  List<Marker> _markers = [];
  List<Polyline> _polylines = [];
  bool _isBookingInProgress = false;
  bool _isRideConfirmed = false;
  double _rideProgress = 0.0;
  Timer? _progressTimer;
  final List<RideHistory> _rideHistory = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }

    final position = await Geolocator.getCurrentPosition();
    setState(() => _currentPosition = position);
    _updateCamera();
  }

  void _updateCamera() {
    if (_currentPosition != null) {
      mapController.move(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        15,
      );
      _updateMarkers();
    }
  }

  void _updateMarkers() {
    final markers = <Marker>[];
    
    if (_currentPosition != null) {
      markers.add(
        Marker(
          point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          child: const Icon(
            Icons.my_location,
            color: Colors.blue,
            size: 40,
          ),
        ),
      );
    }

    if (_selectedStation != null) {
      markers.add(
        Marker(
          point: LatLng(_selectedStation!.latitude, _selectedStation!.longitude),
          child: Icon(
            Icons.location_on,
            color: _getDemandColor(_selectedStation!.demand),
            size: 40,
          ),
        ),
      );
      _drawRoute();
    }

    setState(() => _markers = markers);
  }

  Color _getDemandColor(Demand demand) {
    switch (demand) {
      case Demand.high:
        return Colors.red;
      case Demand.medium:
        return Colors.orange;
      case Demand.low:
        return Colors.green;
    }
  }

  Future<void> _drawRoute() async {
    if (_currentPosition == null || _selectedStation == null) return;

    try {
      final points = await RoutingService.getRoute(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        LatLng(_selectedStation!.latitude, _selectedStation!.longitude),
      );

      setState(() {
        _polylines = [
          Polyline(
            points: points,
            color: Colors.blue,
            strokeWidth: 3,
          ),
        ];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to calculate route: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _bookRide() async {
    if (_selectedStation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a destination station')),
      );
      return;
    }

    setState(() => _isBookingInProgress = true);

    try {
      await Future.delayed(const Duration(seconds: 2)); // Simulated API call
      if (mounted) {
        await _showBookingConfirmation();
        _drawRoute();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to book ride. Please try again.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isBookingInProgress = false);
      }
    }
  }

  Future<void> _showBookingConfirmation() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => BookingConfirmationDialog(
        station: _selectedStation!,
        estimatedTime: '${_selectedStation!.waitTime} mins',
        driverName: 'Rajesh Kumar',
        vehicleNumber: 'DL 1RT 1234',
        onConfirm: () => Navigator.pop(context, true),
        onCancel: () => Navigator.pop(context, false),
      ),
    );

    if (result == true) {
      setState(() => _isRideConfirmed = true);
      _startRideTracking();
    }
  }

  void _startRideTracking() {
    _progressTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        setState(() {
          _rideProgress += 0.01;
          if (_rideProgress >= 1.0) {
            _progressTimer?.cancel();
            _showRideCompletedDialog();
          }
        });
      },
    );
  }

  Future<void> _showRideCompletedDialog() async {
    final ride = RideHistory(
      id: const Uuid().v4(),
      destination: _selectedStation!,
      timestamp: DateTime.now(),
      status: RideStatus.completed,
    );

    setState(() => _rideHistory.add(ride));
    
    await NotificationService.showZoneNotification(
      _selectedStation!.zone,
      stations,
    );

    if (!mounted) return;
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ride Completed'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Thank you for riding with us!'),
            const SizedBox(height: 8),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isRideConfirmed = false;
                _rideProgress = 0.0;
              });
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    super.dispose();
  }

  Future<void> _findNearestStations() async {
    if (_currentPosition == null) return;
    
    final nearestStations = findNearestStations(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      stations,
    );

    setState(() {
      _markers.clear();
      _markers.addAll(
        nearestStations.map((station) => Marker(
          point: LatLng(station.latitude, station.longitude),
          child: Icon(
            Icons.location_on,
            color: _getDemandColor(station.demand),
            size: 40,
          ),
        )),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plan Your Trip')),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: const LatLng(28.7041, 77.1025), // Delhi
              initialZoom: 12,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.lrts',
              ),
              PolylineLayer(polylines: _polylines),
              MarkerLayer(markers: _markers),
            ],
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: StationSearch(
              onStationSelected: (station) {
                setState(() => _selectedStation = station);
                _updateMarkers();
              },
            ),
          ),
          if (_selectedStation != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: ElevatedButton(
                onPressed: _isBookingInProgress ? null : _bookRide,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.blue,
                ),
                child: Text(_isBookingInProgress ? 'Booking...' : 'Book Auto'),
              ),
            ),
          if (_isRideConfirmed)
            RideTrackingOverlay(
              destination: _selectedStation!,
              driverName: 'Rajesh Kumar',
              vehicleNumber: 'DL 1RT 1234',
              estimatedTime: '${_selectedStation!.waitTime} mins',
              progress: _rideProgress,
              onCancel: () {
                _progressTimer?.cancel();
                setState(() {
                  _isRideConfirmed = false;
                  _rideProgress = 0.0;
                });
              },
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _findNearestStations,
        child: const Icon(Icons.near_me),
      ),
    );
  }
} 