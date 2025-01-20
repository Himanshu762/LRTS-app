class Env {
  static const clerkPublishableKey = String.fromEnvironment(
    'CLERK_PUBLISHABLE_KEY',
    defaultValue: '',
  );

  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  static bool get isInitialized =>
      clerkPublishableKey.isNotEmpty &&
      supabaseUrl.isNotEmpty &&
      supabaseAnonKey.isNotEmpty;

  static void validateConfig() {
    if (!isInitialized) {
      throw AssertionError(
        'Environment variables not properly configured. '
        'Please ensure CLERK_PUBLISHABLE_KEY, SUPABASE_URL, and '
        'SUPABASE_ANON_KEY are set.',
      );
    }
  }
} 