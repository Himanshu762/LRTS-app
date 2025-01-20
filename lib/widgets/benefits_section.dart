import 'package:flutter/material.dart';

class BenefitsSection extends StatelessWidget {
  final List<Map<String, dynamic>> benefits = [
    {
      'title': 'Revolutionary Last-Mile Access',
      'description':
          'Unlike traditional options, LRTS provides seamless connectivity from your doorstep to metro stations and back.',
      'icon': Icons.timer,
    },
    {
      'title': 'Subscription-Based Convenience',
      'description':
          'Say goodbye to fare negotiations and cash payments. LRTS offers fixed, affordable subscription plans.',
      'icon': Icons.credit_card,
    },
    {
      'title': 'Smart Fleet Availability',
      'description':
          "Data-driven fleet management ensures you'll always find a rickshaw when you need it, even during peak hours.",
      'icon': Icons.bar_chart,
    },
    {
      'title': 'Safe & Trustworthy Experience',
      'description':
          'All drivers are verified, and vehicles are monitored for safety and reliability.',
      'icon': Icons.shield,
    },
  ];

  BenefitsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[900]
          : Colors.grey[50],
      child: Column(
        children: [
          Text(
            'Benefits',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Why Choose LRTS?',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: benefits.length,
            itemBuilder: (context, index) {
              return Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          benefits[index]['icon'],
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        benefits[index]['title'],
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        benefits[index]['description'],
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
