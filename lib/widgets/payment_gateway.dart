import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lrts/widgets/animated_payment_status.dart';
import 'package:qr_flutter/qr_flutter.dart';

final Map<String, String> cardIcons = {
  'Visa': 'assets/icons/cards/visa.svg',
  'MasterCard': 'assets/icons/cards/mastercard.svg',
  'American Express': 'assets/icons/cards/amex.svg',
  'Discover': 'assets/icons/cards/discover.svg',
  'JCB': 'assets/icons/cards/jcb.svg',
  'Diners Club': 'assets/icons/cards/diners.svg',
  'UnionPay': 'assets/icons/cards/unionpay.svg',
  'Maestro': 'assets/icons/cards/maestro.svg',
  'Unknown': 'assets/icons/cards/generic.svg',
};

final String cvvIcon = 'assets/icons/payment/cvv.svg';

class PaymentGateway extends StatefulWidget {
  final Map<String, dynamic> passDetails;
  final VoidCallback onClose;
  final Function(Map<String, dynamic>) onPaymentSuccess;
  final Function(Map<String, dynamic>)? onPaymentFailure;

  const PaymentGateway({
    super.key,
    required this.passDetails,
    required this.onClose,
    required this.onPaymentSuccess,
    this.onPaymentFailure,
  });

  @override
  State<PaymentGateway> createState() => _PaymentGatewayState();
}

class _PaymentGatewayState extends State<PaymentGateway> with SingleTickerProviderStateMixin {
  final SupabaseClient _supabase = Supabase.instance.client;
  String _activePaymentMode = 'UPI';
  bool _isPaymentProcessing = false;
  String? _selectedPaymentMode;
  String _cardNumber = '';
  String _cardholderName = '';
  String _expiryDate = '';
  String _cvv = '';
  String _cardType = 'Unknown';
  String _selectedBank = '';
  String _selectedWallet = '';
  String _selectedEMI = '';
  String _upiId = '';
  String _qrValue = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _showPaymentStatus = false;
  bool _paymentSuccess = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _generateUPIQR();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _generateUPIQR() {
    final merchantId = 'LRTS${DateTime.now().millisecondsSinceEpoch}';
    final transactionId = const Uuid().v4().substring(0, 12).toUpperCase();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final amount = double.parse(widget.passDetails['price']).toStringAsFixed(2);
    
    final upiUrl = 'upi://pay?pa=lrts@upi&pn=LRTS_METRO'
        '&tr=$transactionId'
        '&tn=${widget.passDetails['title']}'
        '&am=$amount&cu=INR&mc=4121'
        '&mid=$merchantId&sign=$timestamp';
    
    setState(() => _qrValue = upiUrl);
  }

  String _identifyCardType(String cardNumber) {
    final visaRegex = RegExp(r'^4');
    final masterCardRegex = RegExp(r'^5[1-5]');
    final maestroRegex = RegExp(r'^(5018|5020|5038|56|58|63|67)');
    final amexRegex = RegExp(r'^3[47]');
    final discoverRegex = RegExp(r'^6(?:011|4[4-9]|5)');
    final dinersClubRegex = RegExp(r'^3(?:0[0-5]|[689])');
    final jcbRegex = RegExp(r'^(?:2131|1800|35\d{2})');
    final unionPayRegex = RegExp(r'^62');

    if (visaRegex.hasMatch(cardNumber)) return 'Visa';
    if (masterCardRegex.hasMatch(cardNumber)) return 'MasterCard';
    if (maestroRegex.hasMatch(cardNumber)) return 'Maestro';
    if (amexRegex.hasMatch(cardNumber)) return 'American Express';
    if (discoverRegex.hasMatch(cardNumber)) return 'Discover';
    if (dinersClubRegex.hasMatch(cardNumber)) return 'Diners Club';
    if (jcbRegex.hasMatch(cardNumber)) return 'JCB';
    if (unionPayRegex.hasMatch(cardNumber)) return 'UnionPay';
    return 'Unknown';
  }

  final List<String> _validUPISuffixes = [
    '@okhdfcbank', '@okaxis', '@okicici', '@oksbi',
    '@ptyes', '@ptsbi', '@pthdfc', '@ptaxis',
  ];

  bool _isValidUPI(String upiId) {
    return _validUPISuffixes.any((suffix) => upiId.endsWith(suffix));
  }

  Widget _buildUPIScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_qrValue.isNotEmpty)
          QrImageView(
            data: _qrValue,
            size: 200,
          ),
        const SizedBox(height: 16),
        Text(
          'Enter your UPI ID',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: const InputDecoration(
            hintText: 'example@bank',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => setState(() => _upiId = value),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            if (_upiId.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a UPI ID')),
              );
              return;
            }
            if (!_isValidUPI(_upiId)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Invalid UPI ID')),
              );
              return;
            }
            // Proceed with UPI payment
          },
          child: const Text('Proceed with UPI'),
        ),
      ],
    );
  }

  Widget _buildCardsScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter your Card Details',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                cardIcons[_cardType] ?? cardIcons['Unknown']!,
                width: 32,
                height: 32,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Card Number',
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _cardNumber = value;
                      _cardType = _identifyCardType(value);
                    });
                  },
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(16),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: const InputDecoration(
            hintText: 'Cardholder Name',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => setState(() => _cardholderName = value),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'MM/YY',
                  border: OutlineInputBorder(),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                onChanged: (value) => setState(() => _expiryDate = value),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'CVV',
                  border: const OutlineInputBorder(),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SvgPicture.asset(
                      cvvIcon,
                      width: 24,
                      height: 24,
                    ),
                  ),
                ),
                obscureText: true,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                onChanged: (value) => setState(() => _cvv = value),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            if (_cardNumber.isEmpty || _cardholderName.isEmpty || 
                _expiryDate.isEmpty || _cvv.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please fill all card details')),
              );
              return;
            }
            setState(() => _selectedPaymentMode = 'Card: $_cardType ending in ${_cardNumber.substring(_cardNumber.length - 4)}');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Card Verified Successfully!')),
            );
          },
          child: const Text('Verify and Select'),
        ),
      ],
    );
  }

  Widget _buildWalletsScreen() {
    final wallets = [
      'Paytm', 'Google Pay', 'PhonePe', 'Amazon Pay',
      'Mobikwik', 'Freecharge', 'Airtel Money', 'JioMoney'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select your Wallet',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedWallet.isEmpty ? null : _selectedWallet,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: '-- Select Wallet --',
          ),
          items: wallets.map((wallet) => DropdownMenuItem(
            value: wallet,
            child: Text(wallet),
          )).toList(),
          onChanged: (value) => setState(() => _selectedWallet = value ?? ''),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            if (_selectedWallet.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please select a wallet')),
              );
              return;
            }
            setState(() => _selectedPaymentMode = 'Wallet: $_selectedWallet');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Wallet Selected Successfully')),
            );
          },
          child: const Text('Select Wallet'),
        ),
      ],
    );
  }

  Widget _buildNetBankingScreen() {
    final banks = [
      'HDFC', 'SBI', 'ICICI', 'Axis Bank', 'Kotak Mahindra',
      'Punjab National Bank', 'Bank of Baroda', 'Canara Bank',
      'Yes Bank', 'IDBI Bank'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select your Bank',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedBank.isEmpty ? null : _selectedBank,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: '-- Select Bank --',
          ),
          items: banks.map((bank) => DropdownMenuItem(
            value: bank,
            child: Text(bank),
          )).toList(),
          onChanged: (value) => setState(() => _selectedBank = value ?? ''),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            if (_selectedBank.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please select a bank')),
              );
              return;
            }
            setState(() => _selectedPaymentMode = 'Net Banking: $_selectedBank');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Bank Selected Successfully')),
            );
          },
          child: const Text('Select Bank'),
        ),
      ],
    );
  }

  Widget _buildEMIScreen() {
    final emiOptions = ['3 months', '6 months', '12 months'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select EMI Option',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedEMI.isEmpty ? null : _selectedEMI,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: '-- Select EMI --',
          ),
          items: emiOptions.map((emi) => DropdownMenuItem(
            value: emi,
            child: Text(emi),
          )).toList(),
          onChanged: (value) => setState(() => _selectedEMI = value ?? ''),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            if (_selectedEMI.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please select an EMI option')),
              );
              return;
            }
            setState(() => _selectedPaymentMode = 'EMI: $_selectedEMI');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('EMI Selected Successfully')),
            );
          },
          child: const Text('Select EMI'),
        ),
      ],
    );
  }

  Widget _buildPaymentContent() {
    switch (_activePaymentMode) {
      case 'UPI':
        return _buildUPIScreen();
      case 'Cards':
        return _buildCardsScreen();
      case 'Wallets':
        return _buildWalletsScreen();
      case 'Net Banking':
        return _buildNetBankingScreen();
      case 'EMI':
        return _buildEMIScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _handlePayment() async {
    if (_selectedPaymentMode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment mode')),
      );
      return;
    }

    setState(() => _isPaymentProcessing = true);
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final newPass = {
        'user_id': user.uid,
        'name': user.displayName ?? 'Unknown User',
        'email': user.email,
        'pass_type': widget.passDetails['title'],
        'price': widget.passDetails['price'],
        'home_zone': widget.passDetails['homeZone'],
        'destination_zone': widget.passDetails['destinationZone'],
        'pass_secret': const Uuid().v4(),
        'payment_mode': _selectedPaymentMode,
        'created_at': DateTime.now().toIso8601String(),
      };

      // Show payment animation
      setState(() {
        _showPaymentStatus = true;
        _paymentSuccess = true;
      });

      // Optimistically update UI
      widget.onPaymentSuccess(newPass);
      
      // Attempt to save to database
      final response = await _supabase.from('passes').insert(newPass);

      if (response.error != null) {
        throw response.error!;
      }

    } catch (e) {
      setState(() => _paymentSuccess = false);
      widget.onPaymentFailure?.call({
        'pass_secret': widget.passDetails['pass_secret'],
        // Include other relevant pass details if necessary
      });
    } finally {
      if (mounted) {
        setState(() => _isPaymentProcessing = false);
      }
    }
  }

  Widget _buildPaymentStatus() {
    return AnimatedPaymentStatus(
      isSuccess: _paymentSuccess,
      onAnimationComplete: () {
        if (_paymentSuccess) {
          widget.onClose();
        } else {
          setState(() => _showPaymentStatus = false);
        }
      },
    );
  }

  void _setActivePaymentMode(String mode) {
    setState(() {
      _activePaymentMode = mode;
      if (mode == 'UPI') {
        _generateUPIQR();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showPaymentStatus) {
      return _buildPaymentStatus();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Left Panel - Payment Summary
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade900,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'LRTS.com',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.passDetails['title'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '₹${widget.passDetails['price']}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Right Panel - Payment Options
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  for (final mode in ['UPI', 'Cards', 'Wallets', 'Net Banking', 'EMI'])
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: ChoiceChip(
                                        label: Text(mode),
                                        selected: _activePaymentMode == mode,
                                        onSelected: (selected) {
                                          if (selected) {
                                            _setActivePaymentMode(mode);
                                          }
                                        },
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Expanded(
                              child: SingleChildScrollView(
                                child: _buildPaymentContent(),
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _isPaymentProcessing ? null : _handlePayment,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                minimumSize: const Size(double.infinity, 48),
                              ),
                              child: Text(_isPaymentProcessing ? 'Processing...' : 'Pay'),
                            ),
                          ],
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