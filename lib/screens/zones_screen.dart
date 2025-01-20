import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lrts/models/station.dart';
import 'package:lrts/widgets/zone_stats_card.dart';
import 'package:lrts/data/stations.dart';
import 'package:lrts/widgets/station_info_sheet.dart';

class ZonesScreen extends StatefulWidget {
  const ZonesScreen({super.key});

  @override
  State<ZonesScreen> createState() => _ZonesScreenState();
}

class _ZonesScreenState extends State<ZonesScreen> {
  String? selectedZone;
  final mapController = MapController();

  void _selectZone(String zoneName) {
    setState(() {
      selectedZone = zoneName;
    });
    
    final station = delhiMetroStations.firstWhere(
      (s) => s.name == zoneName,
      orElse: () => delhiMetroStations.first,
    );
    
    mapController.move(
      LatLng(station.latitude, station.longitude),
      14.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('LRTS Zones'),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ZoneStatsCard(
                    zoneName: 'All Zones',
                    stations: delhiMetroStations,
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: delhiMetroStations.map((station) {
                        final isSelected = selectedZone == station.name;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            selected: isSelected,
                            label: Text(station.name),
                            onSelected: (_) => _selectZone(station.name),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 400,
                    child: FlutterMap(
                      mapController: mapController,
                      options: MapOptions(
                        initialCenter: LatLng(28.6139, 77.2090),
                        initialZoom: 11.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.lrts',
                        ),
                        CircleLayer(
                          circles: delhiMetroStations.map((station) {
                            final isSelected = selectedZone == station.name;
                            return CircleMarker(
                              point: LatLng(station.latitude, station.longitude),
                              radius: 2000,
                              color: isSelected 
                                ? Colors.blue.withOpacity(0.3)
                                : Colors.blue.withOpacity(0.1),
                              borderColor: Colors.blue,
                              borderStrokeWidth: isSelected ? 2 : 1,
                            );
                          }).toList(),
                        ),
                        MarkerLayer(
                          markers: delhiMetroStations.map((station) {
                            return Marker(
                              point: LatLng(station.latitude, station.longitude),
                              child: GestureDetector(
                                onTap: () => _showStationInfo(context, station),
                                child: const Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                  size: 40,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 160,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        'North',
                        'South',
                        'East',
                        'West',
                        'Central',
                      ].map((zone) => Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: SizedBox(
                          width: 280,
                          child: ZoneStatsCard(
                            zoneName: zone,
                            stations: stations,
                          ),
                        ),
                      )).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showStationInfo(BuildContext context, Station station) {
    showModalBottomSheet(
      context: context,
      builder: (context) => StationInfoSheet(station: station),
    );
  }
} 