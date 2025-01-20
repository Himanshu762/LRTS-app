import 'package:flutter/material.dart';
import 'package:lrts/models/station.dart';

class StationSearch extends StatelessWidget {
  final Function(Station) onStationSelected;

  const StationSearch({
    super.key,
    required this.onStationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Autocomplete<Station>(
        optionsBuilder: (TextEditingValue textEditingValue) {
          return stations.where((station) =>
            station.name.toLowerCase().contains(textEditingValue.text.toLowerCase())
          );
        },
        onSelected: onStationSelected,
        displayStringForOption: (station) => station.name,
        fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
          return TextField(
            controller: controller,
            focusNode: focusNode,
            decoration: InputDecoration(
              hintText: 'Search for a metro station',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          );
        },
        optionsViewBuilder: (context, onSelected, options) {
          return Material(
            elevation: 4,
            child: ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: options.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final station = options.elementAt(index);
                return ListTile(
                  onTap: () => onSelected(station),
                  leading: Icon(
                    Icons.train,
                    color: station.demand == Demand.high 
                        ? Colors.red 
                        : station.demand == Demand.medium 
                            ? Colors.orange 
                            : Colors.green,
                  ),
                  title: Text(station.name),
                  subtitle: Text('${station.zone} Zone'),
                  trailing: Chip(
                    label: Text('${station.waitTime} min'),
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
} 