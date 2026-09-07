import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/worker_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/admin_provider.dart';
import 'services/firebase_realtime_service.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/household/household_home_screen.dart';
import 'screens/household/booking_detail_screen.dart';
import 'screens/household/book_service_screen.dart';
import 'screens/household/online_consultation_screen.dart';
import 'screens/worker/worker_home_screen.dart';
import 'screens/worker/worker_messages_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'utils/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Resilient Firebase initialization with error safety
  try {
    await FirebaseRealtimeService().initialize();
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => WorkerProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: const CooperativeGigApp(),
    ),
  );
}

class CooperativeGigApp extends StatelessWidget {
  const CooperativeGigApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cooperative Gig Services',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF5B21B6),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1E293B),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Color(0xFF1E293B)),
        ),
      ),
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (context) => const SplashScreen(),
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.signup: (context) => const RegisterScreen(),
        AppRoutes.householdHome: (context) => const HouseholdHomeScreen(),
        AppRoutes.bookingStatus: (context) => const BookingDetailScreen(),
        '/booking_detail': (context) => const BookingDetailScreen(),
        '/book_service': (context) => const BookServiceScreen(),
        '/online_consultation': (context) => const OnlineConsultationScreen(),
        '/worker_messages': (context) => const WorkerMessagesScreen(),
        AppRoutes.workerHome: (context) => const WorkerHomeScreen(),
        '/admin_dashboard': (context) => const AdminDashboardScreen(),
      },
    );
  }
}
