import 'package:flutter/material.dart';
import 'package:lrts/models/pass.dart';
import 'package:lrts/widgets/pass_card.dart';
import 'package:lrts/screens/zone_selection_screen.dart';

class BuyAnotherPassModal extends StatefulWidget {
  final VoidCallback onClose;
  final Function(Map<String, dynamic>) onPassPurchased;

  const BuyAnotherPassModal({
    super.key,
    required this.onClose,
    required this.onPassPurchased,
  });

  @override
  State<BuyAnotherPassModal> createState() => _BuyAnotherPassModalState();
}

class _BuyAnotherPassModalState extends State<BuyAnotherPassModal> {
  Pass? selectedPass;

  final List<Pass> passes = [
    Pass(
      title: 'Daily Pass - Single Trip',
      price: '17',
      duration: 'trip',
      features: ['Single trip to any metro station in the zone'],
    ),
    Pass(
      title: 'Daily Pass - Single Zone',
      price: '35',
      duration: 'day',
      features: ['Up to 2 rides/day in one zone'],
    ),
    Pass(
      title: 'Daily Pass - Dual Zone',
      price: '95',
      duration: 'day',
      features: ['Up to 4 rides/day across two zones'],
    ),
  ];

  void _handlePassSelection(BuildContext context, Pass pass) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => ZoneSelectionScreen(
          pass: pass,
          onPassPurchased: widget.onPassPurchased,
        ),
      ),
    );

    if (result != null) {
      widget.onPassPurchased(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Buy Another Pass',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: widget.onClose,
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.6,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: passes.length,
                itemBuilder: (context, index) {
                  return PassCard(
                    pass: passes[index],
                    insideBuyAnotherPassModal: true,
                    onCardClick: () => _handlePassSelection(context, passes[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
} 