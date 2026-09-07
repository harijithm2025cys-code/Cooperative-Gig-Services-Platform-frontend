import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:cooperative_gig_services/l10n/app_localizations.dart';
import 'package:cooperative_gig_services/providers/locale_provider.dart';
import 'package:cooperative_gig_services/widgets/language_selector.dart';
import 'package:cooperative_gig_services/models/booking.dart';

void main() {
  group('Phase 9 Multilingual Localization & Dictionary Verification', () {
    test('English AppLocalizations returns expected strings', () {
      final loc = AppLocalizations(const Locale('en'));

      expect(loc.appTitle, 'Cooperative Gig Services Platform');
      expect(loc.login, 'Sign In');
      expect(loc.bookService, 'Book Service');
      expect(loc.emergencyService, 'Emergency Booking (Immediate Dispatch)');
      expect(loc.paymentPending, 'Payment Pending');
      expect(loc.paymentCaptured, 'Payment Successful & Captured');
      expect(loc.workerAssigned, 'Worker Assigned');
      expect(loc.onTheWay, 'Specialist On The Way');
      expect(loc.arrived, 'Specialist Arrived on Site');
      expect(loc.inProgress, 'Service In Progress');
      expect(loc.completed, 'Service Completed — Awaiting Customer Acceptance');
      expect(loc.rateService, 'Rate Cooperative Service Quality');
      expect(loc.fixedPricingGuarantee, 'Fixed Cooperative Pricing Guarantee');
      expect(loc.isTamil, false);
    });

    test('Tamil AppLocalizations returns natural, culturally accurate Tamil terms', () {
      final loc = AppLocalizations(const Locale('ta'));

      expect(loc.appTitle, 'கூட்டுறவு கிக் சேவைகள் தளம்');
      expect(loc.login, 'உள்நுழைக');
      expect(loc.bookService, 'சேவையை முன்பதிவு செய்க');
      expect(loc.paymentCaptured, 'பணம் செலுத்துதல் வெற்றிகரமாக முடிந்தது');
      expect(loc.workerAssigned, 'பணியாளர் ஒதுக்கப்பட்டார்');
      expect(loc.onTheWay, 'பணியாளர் வந்து கொண்டிருக்கிறார்');
      expect(loc.arrived, 'பணியாளர் வந்து சேர்ந்தார்');
      expect(loc.inProgress, 'பணி நடைபெறுகிறது');
      expect(loc.customerInspectionTitle, 'வாடிக்கையாளர் ஆய்வு மற்றும் ஏற்பு சரிபார்ப்பு');
      expect(loc.taxInvoice, 'அதிகாரப்பூர்வ வரி விலைப்பட்டியல்');
      expect(loc.isTamil, true);
    });

    test('formatCurrency formats Indian Rupees correctly in both languages', () {
      final locEn = AppLocalizations(const Locale('en'));
      final locTa = AppLocalizations(const Locale('ta'));

      expect(locEn.formatCurrency(450.0), '₹450.00');
      expect(locTa.formatCurrency(1250.50), '₹1250.50');
    });

    test('AppLocalizations delegate supports English and Tamil', () {
      expect(AppLocalizations.delegate.isSupported(const Locale('en')), isTrue);
      expect(AppLocalizations.delegate.isSupported(const Locale('ta')), isTrue);
      expect(AppLocalizations.delegate.isSupported(const Locale('fr')), isFalse);
    });
  });

  group('Phase 9 LocaleProvider State Management & Switching', () {
    test('LocaleProvider initializes and toggles language without re-authentication', () async {
      final provider = LocaleProvider();

      expect(provider.currentLocale.languageCode, 'en');
      expect(provider.isTamil, false);

      await provider.setLocale(const Locale('ta'));
      expect(provider.currentLocale.languageCode, 'ta');
      expect(provider.isTamil, true);

      await provider.toggleLanguage();
      expect(provider.currentLocale.languageCode, 'en');
      expect(provider.isTamil, false);
    });
  });

  group('Phase 9 LanguageSelector Widget UI Tests', () {
    testWidgets('Compact LanguageSelector renders and responds to tap', (WidgetTester tester) async {
      final localeProvider = LocaleProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: localeProvider,
          child: const MaterialApp(
            home: Scaffold(
              body: LanguageSelector(compact: true),
            ),
          ),
        ),
      );

      // Verify EN is shown
      expect(find.text('EN'), findsOneWidget);
      expect(find.byIcon(Icons.language), findsOneWidget);

      // Tap to toggle
      await tester.tap(find.byType(LanguageSelector));
      await tester.pumpAndSettle();

      // Now Tamil should be shown
      expect(find.text('தமிழ்'), findsOneWidget);
    });

    testWidgets('Full segmented LanguageSelector renders both English and Tamil options', (WidgetTester tester) async {
      final localeProvider = LocaleProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: localeProvider,
          child: const MaterialApp(
            home: Scaffold(
              body: LanguageSelector(compact: false),
            ),
          ),
        ),
      );

      expect(find.text('English'), findsOneWidget);
      expect(find.text('தமிழ்'), findsOneWidget);

      // Tap Tamil option
      await tester.tap(find.text('தமிழ்'));
      await tester.pumpAndSettle();

      expect(localeProvider.isTamil, true);
    });
  });

  group('Phase 9 Payment-Before-Service & Production Guardrails', () {
    test('Payment-Before-Service: Unpaid booking status is paymentPending at step 0', () {
      final unpaidBooking = Booking(
        id: 'bk_guardrail_01',
        workerId: 'wrk_01',
        workerName: 'Ramesh Patel',
        workerSkill: 'Electrician',
        workerPhone: '9876543210',
        householdId: 'hh_01',
        householdName: 'Ananya Sharma',
        householdPhone: '9123456780',
        serviceAddress: '123 Anna Salai, Chennai',
        status: BookingStatus.paymentPending,
        paymentStatus: PaymentStatus.pending,
        amount: 450.0,
        scheduledDate: '2026-09-08',
        scheduledTime: '10:00 AM',
        createdAt: DateTime.now(),
      );

      expect(unpaidBooking.status, BookingStatus.paymentPending);
      expect(unpaidBooking.status.stepIndex, 0);
      expect(unpaidBooking.paymentStatus, PaymentStatus.pending);
    });

    test('Captured payment booking is ready for worker dispatch at Step 1 or Step 2', () {
      final paidBooking = Booking(
        id: 'bk_guardrail_02',
        workerId: 'wrk_01',
        workerName: 'Ramesh Patel',
        workerSkill: 'Electrician',
        workerPhone: '9876543210',
        householdId: 'hh_01',
        householdName: 'Ananya Sharma',
        householdPhone: '9123456780',
        serviceAddress: '123 Anna Salai, Chennai',
        status: BookingStatus.accepted,
        paymentStatus: PaymentStatus.captured,
        amount: 450.0,
        scheduledDate: '2026-09-08',
        scheduledTime: '10:00 AM',
        createdAt: DateTime.now(),
      );

      expect(paidBooking.paymentStatus, PaymentStatus.captured);
      expect(paidBooking.status.stepIndex, 2);
    });
  });
}
