import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter/material.dart';
import 'package:lrts/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final SupabaseClient _supabase;
  bool _isLoading = true;
  firebase.User? _user;

  AuthProvider(SupabaseClient supabase) 
      : _authService = AuthService(),
        _supabase = supabase {
    _initialize();
  }

  bool get isLoading => _isLoading;
  firebase.User? get user => _user;
  bool get isAuthenticated => _user != null;

  Future<void> _initialize() async {
    try {
      _authService.authStateChanges.listen((user) {
        _user = user;
        notifyListeners();
      });
    } catch (e) {
      debugPrint('Error initializing auth: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      await _authService.signInWithGoogle();
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      rethrow;
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    try {
      await _authService.signInWithEmail(email, password);
    } catch (e) {
      debugPrint('Error signing in with email: $e');
      rethrow;
    }
  }

  Future<void> signUpWithEmail(String email, String password) async {
    try {
      await _authService.signUpWithEmail(email, password);
    } catch (e) {
      debugPrint('Error signing up with email: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
      rethrow;
    }
  }

  // Method to get user passes from Supabase
  Future<List<Map<String, dynamic>>> getUserPasses() async {
    if (!isAuthenticated) {
      return [];
    }

    try {
      final response = await _supabase
          .from('passes')
          .select();
          
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching user passes: $e');
      return [];
    }
  }

  // Method to save a new pass to Supabase
  Future<bool> saveUserPass({
    required String passType,
    required String price,
    required String homeZone,
    required String destinationZone,
    required String paymentMode,
  }) async {
    if (!isAuthenticated) {
      return false;
    }

    try {
      final response = await _supabase
          .from('passes')
          .insert({
            'email': _user?.email ?? '',
            'pass_type': passType,
            'price': price,
            'home_zone': homeZone,
            'destination_zone': destinationZone,
            'payment_mode': paymentMode,
          });

      if (response.error != null) {
        throw response.error!;
      }

      return true;
    } catch (e) {
      debugPrint('Error saving user pass: $e');
      return false;
    }
  }
} 