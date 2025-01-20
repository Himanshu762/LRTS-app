import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lrts/providers/auth_provider.dart';
import 'package:lrts/providers/theme_provider.dart';
import 'package:lrts/screens/home_screen.dart';
import 'package:lrts/screens/auth/sign_in_screen.dart';
import 'package:lrts/screens/auth/sign_up_screen.dart';
import 'package:lrts/screens/account_screen.dart';
import 'package:lrts/screens/passes_screen.dart';
import 'package:lrts/screens/zones_screen.dart';
import 'package:lrts/screens/trip_planner_screen.dart';
import 'package:lrts/widgets/protected_route.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  try {
    // Initialize Firebase
    await Firebase.initializeApp();
    debugPrint('Firebase initialized successfully');

    // Initialize Supabase
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? '',
      anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    );
    debugPrint('Supabase initialized successfully');

    runApp(const MyApp());
  } catch (e) {
    debugPrint('Error initializing app: $e');
    runApp(const InitializationErrorApp());
  }
}

// Error fallback app
class InitializationErrorApp extends StatelessWidget {
  const InitializationErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            'Failed to initialize app.\nPlease check your configuration.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red[700]),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(Supabase.instance.client),
        ),
      ],
      child: Builder(
        builder: (context) => MaterialApp(
          navigatorKey: navigatorKey,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: context.watch<ThemeProvider>().themeMode,
          initialRoute: '/',
          routes: {
            '/': (context) => const HomeScreen(),
            '/signin': (context) => const SignInScreen(),
            '/signup': (context) => const SignUpScreen(),
            '/account': (context) => const AccountScreen(),
            '/passes': (context) => const PassesScreen(),
            '/zones': (context) => const ProtectedRoute(child: ZonesScreen()),
            '/trip-planner': (context) => const ProtectedRoute(
                  child: TripPlannerScreen(userPasses: []),
                ),
          },
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const ZonesScreen(),
    const TripPlannerScreen(userPasses: []),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.map),
            label: 'Zones',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions),
            label: 'Trip Planner',
          ),
        ],
      ),
    );
  }
}
