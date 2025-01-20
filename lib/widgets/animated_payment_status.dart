import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AnimatedPaymentStatus extends StatelessWidget {
  final bool isSuccess;
  final VoidCallback onAnimationComplete;

  const AnimatedPaymentStatus({
    super.key,
    required this.isSuccess,
    required this.onAnimationComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LottieBuilder.asset(
        isSuccess 
          ? 'assets/animations/payment_success.json'
          : 'assets/animations/payment_failed.json',
        repeat: false,
        onLoaded: (composition) {
          Future.delayed(composition.duration, onAnimationComplete);
        },
      ),
    );
  }
} 