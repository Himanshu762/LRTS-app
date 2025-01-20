import 'package:flutter/material.dart';
import 'package:lrts/models/pass.dart';
import 'package:qr_flutter/qr_flutter.dart';

class UserPasses extends StatefulWidget {
  final List<Pass> passes;

  const UserPasses({
    super.key,
    required this.passes,
  });

  @override
  State<UserPasses> createState() => _UserPassesState();
}

class _UserPassesState extends State<UserPasses> {
  Pass? selectedPass;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.586,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: widget.passes.length,
          itemBuilder: (context, index) {
            final pass = widget.passes[index];
            return GestureDetector(
              onTap: () => setState(() => selectedPass = pass),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, Colors.blue],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  pass.title,
                                  style: Theme.of(context).textTheme.titleSmall,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Icon(Icons.credit_card, size: 16),
                            ],
                          ),
                          if (pass.homeZone != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Home Zone: ${pass.homeZone}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                          if (pass.destinationZone != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Destination: ${pass.destinationZone}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '₹${pass.price}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          if (pass.passSecret != null)
                            QrImageView(
                              data: pass.passSecret!,
                              size: 32,
                              version: QrVersions.auto,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        if (selectedPass != null)
          _buildPassDetailsModal(),
      ],
    );
  }

  Widget _buildPassDetailsModal() {
    return Container(
      // Modal implementation
    );
  }
} 