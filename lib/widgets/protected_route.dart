import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lrts/providers/auth_provider.dart';
import 'package:lrts/screens/auth/sign_in_screen.dart';

class ProtectedRoute extends StatelessWidget {
  final Widget child;

  const ProtectedRoute({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!authProvider.isAuthenticated) {
          return const SignInScreen();
        }

        return child;
      },
    );
  }
} 