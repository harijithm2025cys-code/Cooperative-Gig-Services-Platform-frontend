import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:cooperative_gig_services/main.dart';
import 'package:cooperative_gig_services/providers/auth_provider.dart';
import 'package:cooperative_gig_services/providers/worker_provider.dart';
import 'package:cooperative_gig_services/providers/booking_provider.dart';
import 'package:cooperative_gig_services/providers/admin_provider.dart';

void main() {
  testWidgets('App loads splash screen successfully with providers', (WidgetTester tester) async {
    await tester.pumpWidget(
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

    // Verify that splash screen content renders
    expect(find.text('Cooperative Gig Services'), findsOneWidget);
    expect(find.text('Trusted Cooperative Services'), findsOneWidget);

    // Advance frame
    await tester.pump(const Duration(seconds: 1));
  });
}
