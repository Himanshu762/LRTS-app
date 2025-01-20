import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lrts/providers/auth_provider.dart';
import 'package:lrts/widgets/pass_card.dart';
import 'package:lrts/widgets/user_passes.dart';
import 'package:lrts/widgets/buy_another_pass_modal.dart';
import 'package:lrts/models/pass.dart';

class PassesScreen extends StatefulWidget {
  const PassesScreen({super.key});

  @override
  State<PassesScreen> createState() => _PassesScreenState();
}

class _PassesScreenState extends State<PassesScreen> {
  bool _isModalOpen = false;
  List<Map<String, dynamic>> _userPasses = [];
  bool _isLoading = true;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  final List<Pass> passes = [
    Pass(
      title: 'Daily Pass - Single Trip',
      price: '25',
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
      price: '79',
      duration: 'day',
      features: ['Up to 4 rides/day across two zones'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserPasses();
  }

  Future<void> _loadUserPasses() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      final passes = await authProvider.getUserPasses();
      if (mounted) {
        setState(() {
          _userPasses = passes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load passes')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleOptimisticUpdate(Map<String, dynamic> newPass) {
    setState(() {
      _userPasses = [..._userPasses, newPass];
      _isModalOpen = false;
    });
    
    _listKey.currentState?.insertItem(
      _userPasses.length - 1,
      duration: const Duration(milliseconds: 300),
    );
  }

  void _handleUpdateFailure(Map<String, dynamic> failedPass) {
    final index = _userPasses.indexWhere(
      (pass) => pass['pass_secret'] == failedPass['pass_secret']
    );
    
    if (index != -1) {
      final removedPass = _userPasses[index];
      setState(() {
        _userPasses.removeAt(index);
      });
      
      _listKey.currentState?.removeItem(
        index,
        (context, animation) => SizeTransition(
          sizeFactor: animation,
          child: FadeTransition(
            opacity: animation,
            child: PassCard(pass: removedPass),
          ),
        ),
        duration: const Duration(milliseconds: 300),
      );
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Failed to save pass. Please try again.'),
        action: SnackBarAction(
          label: 'Retry',
          onPressed: () => _retryPayment(failedPass),
        ),
      ),
    );
  }

  Future<void> _retryPayment(Map<String, dynamic> pass) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      final success = await authProvider.saveUserPass(
        passType: pass['pass_type'],
        price: pass['price'],
        homeZone: pass['home_zone'],
        destinationZone: pass['destination_zone'],
        paymentMode: pass['payment_mode'],
      );
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pass saved successfully!')),
        );
      } else {
        _handleUpdateFailure(pass);
      }
    } catch (e) {
      _handleUpdateFailure(pass);
    }
  }

  Widget _buildBuyAnotherPassModal() {
    return BuyAnotherPassModal(
      onClose: () => setState(() => _isModalOpen = false),
      onPassPurchased: _handleOptimisticUpdate,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_isModalOpen) {
      return Stack(
        children: [
          const PassesScreen(),
          _buildBuyAnotherPassModal(),
        ],
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_userPasses.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Your Purchased Passes',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => setState(() => _isModalOpen = true),
                      child: const Text('Buy Another Pass'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                UserPasses(passes: _userPasses.map((p) => Pass.fromMap(p)).toList()),
              ] else
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.indigo.shade50,
                        Colors.indigo.shade100,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Choose Your Pass',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Select the perfect pass that suits your travel needs',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[700],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      AnimatedList(
                        key: _listKey,
                        initialItemCount: passes.length,
                        itemBuilder: (context, index, animation) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: SlideTransition(
                            position: animation.drive(
                              Tween<Offset>(
                                begin: const Offset(1, 0),
                                end: Offset.zero,
                              ).chain(CurveTween(curve: Curves.easeInOut)),
                            ),
                            child: PassCard(pass: passes[index]),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
} 