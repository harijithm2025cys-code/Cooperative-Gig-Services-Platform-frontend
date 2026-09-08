import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:cooperative_gig_services/providers/locale_provider.dart';
import 'package:cooperative_gig_services/providers/auth_provider.dart';
import 'package:cooperative_gig_services/providers/worker_provider.dart';
import 'package:cooperative_gig_services/providers/booking_provider.dart';
import 'package:cooperative_gig_services/providers/admin_provider.dart';
import 'package:cooperative_gig_services/screens/auth/login_screen.dart';
import 'package:cooperative_gig_services/screens/chat/chatbot_screen.dart';
import 'package:cooperative_gig_services/screens/household/problem_description_screen.dart';
import 'package:cooperative_gig_services/screens/welfare/welfare_screen.dart';

Widget createTestApp(Widget home) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ChangeNotifierProvider(create: (_) => AuthProvider()),
      ChangeNotifierProvider(create: (_) => WorkerProvider()),
      ChangeNotifierProvider(create: (_) => BookingProvider()),
      ChangeNotifierProvider(create: (_) => AdminProvider()),
    ],
    child: MaterialApp(
      home: home,
      routes: {
        '/household_home': (_) => const Scaffold(body: Text('Household Screen')),
        '/worker_home': (_) => const Scaffold(body: Text('Worker Screen')),
        '/admin_dashboard': (_) => const Scaffold(body: Text('Admin Screen')),
        '/signup': (_) => const Scaffold(body: Text('Signup Screen')),
      },
    ),
  );
}

void main() {
  group('SIH_2026 Reference Features & Modern UI Tests', () {
    testWidgets('LoginScreen renders modern UI with 4 1-tap demo login tiles', (tester) async {
      await tester.pumpWidget(createTestApp(const LoginScreen()));
      await tester.pumpAndSettle();

      // Header verification
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Login with your phone number or email'), findsOneWidget);

      // Input fields
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('Phone / Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Login'), findsNWidgets(2)); // AppBar and Button

      // 4 Quick Demo Tiles
      expect(find.text('Quick Demo Accounts (1-Tap Login)'), findsOneWidget);
      expect(find.text('Demo Customer (Ananya Sharma)'), findsOneWidget);
      expect(find.text('Demo Worker (Ramesh Kumar)'), findsOneWidget);
      expect(find.text('Demo Cooperative (Priya Menon)'), findsOneWidget);
      expect(find.text('Demo Platform Admin'), findsOneWidget);
    });

    testWidgets('ChatbotScreen renders Service Assistant with quick action chips', (tester) async {
      await tester.pumpWidget(createTestApp(const ChatbotScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Service Assistant'), findsOneWidget);
      expect(find.text('How to book a service?'), findsOneWidget);
      expect(find.text('Emergency service'), findsOneWidget);
      expect(find.text('Payment & UPI options'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      // Tap a quick prompt
      await tester.tap(find.text('Emergency service'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Emergency service'), findsWidgets);
    });

    testWidgets('ProblemDescriptionScreen analyzes text and suggests specialists', (tester) async {
      await tester.pumpWidget(createTestApp(const ProblemDescriptionScreen()));
      await tester.pumpAndSettle();

      expect(find.text('AI Problem Matcher'), findsOneWidget);
      expect(find.text('Natural Language AI Matcher'), findsOneWidget);
      expect(find.text('Describe your problem:'), findsOneWidget);
      expect(find.text('Find Matching Workers'), findsOneWidget);

      // Tap a sample prompt
      expect(find.text('Kitchen sink pipe burst and water leaking'), findsOneWidget);
      await tester.tap(find.text('Kitchen sink pipe burst and water leaking'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Check analysis output
      expect(find.text('Matched Specialists'), findsOneWidget);
      expect(find.text('Skill: Plumber'), findsOneWidget);
    });

    testWidgets('WelfareScreen displays fund health and social security schemes', (tester) async {
      await tester.pumpWidget(createTestApp(const WelfareScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Welfare & Social Security'), findsOneWidget);
      expect(find.text('Cooperative Welfare Fund'), findsOneWidget);
      expect(find.text('₹ 14,82,500'), findsOneWidget);
      expect(find.text('85% Good Standing'), findsOneWidget);

      // Verify Government Schemes
      expect(find.text('PMJJBY — Life Insurance'), findsOneWidget);
      expect(find.text('PMSBY — Accident Insurance'), findsOneWidget);
      expect(find.text('Ayushman Bharat — PM-JAY'), findsOneWidget);
      expect(find.text('Cooperative Emergency Relief Grant'), findsOneWidget);
      expect(find.text('Apply for Assistance / Claim'), findsOneWidget);
    });
  });
}
