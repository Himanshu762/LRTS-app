import 'package:flutter/material.dart';
import 'package:lrts/screens/passes_screen.dart';
import 'package:lrts/screens/zones_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                'https://i.natgeofe.com/n/6a70a49b-562a-49de-bfdf-38ee3e4102bd/51477_4x3.jpg',
                fit: BoxFit.cover,
              ),
              title: const Text('Your Local Rickshaw Transit System'),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Experience convenient, eco-friendly last-mile connectivity with our modern rickshaw network.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PassesScreen(),
                              ),
                            );
                          },
                          child: const Text('Get Your Pass'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ZonesScreen(),
                              ),
                            );
                          },
                          child: const Text('Explore Zones'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 