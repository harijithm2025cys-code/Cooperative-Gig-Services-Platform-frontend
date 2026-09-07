import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:cooperative_gig_services/models/user.dart';
import 'package:cooperative_gig_services/config/api_config.dart';
import 'package:cooperative_gig_services/providers/auth_provider.dart';
import 'package:cooperative_gig_services/providers/admin_provider.dart';
import 'package:cooperative_gig_services/screens/admin/admin_dashboard_screen.dart';

class MockAdminProvider extends AdminProvider {
  @override
  Future<void> fetchAssociationData({String? cooperativeId}) async {
    // Immediate completion for widget test without network call
  }

  @override
  Future<void> fetchSuperAdminData() async {
    // Immediate completion for widget test without network call
  }
}

void main() {
  group('Phase 6: Five-Role System & Management Endpoints', () {
    test('UserRole enum parses and maps all 5 roles correctly', () {
      expect(UserRole.fromString('customer'), UserRole.customer);
      expect(UserRole.fromString('independent_worker'), UserRole.independentWorker);
      expect(UserRole.fromString('cooperative_worker'), UserRole.cooperativeWorker);
      expect(UserRole.fromString('cooperative_association_head'), UserRole.cooperativeAssociationHead);
      expect(UserRole.fromString('super_admin'), UserRole.superAdmin);

      // Verify role properties on User
      const assocHead = User(
        id: 'usr_head_01',
        name: 'Head Sundar',
        phone: '+91 98400 11001',
        email: 'head@coop.org',
        role: UserRole.cooperativeAssociationHead,
        cooperativeId: 'coop_north_01',
      );
      expect(assocHead.isAssociationHead, isTrue);
      expect(assocHead.isSuperAdmin, isFalse);
      expect(assocHead.isCustomer, isFalse);

      const superAdmin = User(
        id: 'usr_admin_01',
        name: 'Super Admin',
        phone: '+91 98400 00001',
        email: 'admin@gov.in',
        role: UserRole.superAdmin,
      );
      expect(superAdmin.isSuperAdmin, isTrue);
      expect(superAdmin.isAssociationHead, isFalse);
    });

    test('ApiConfig contains all Phase 6 Association and Super Admin endpoints', () {
      expect(ApiConfig.associationDashboard, '/association/dashboard');
      expect(ApiConfig.associationWorkers, '/association/workers');
      expect(ApiConfig.associationServices, '/association/services');
      expect(ApiConfig.associationBookings, '/association/bookings');
      expect(ApiConfig.associationOperations, '/association/operations');
      expect(ApiConfig.associationAssignments, '/association/assignments');
      expect(ApiConfig.associationDisputes, '/association/disputes');
      expect(ApiConfig.associationPayments, '/association/payments');
      expect(ApiConfig.associationAnalytics, '/association/analytics');

      expect(ApiConfig.adminDashboard, '/admin/dashboard');
      expect(ApiConfig.adminUsers, '/admin/users');
      expect(ApiConfig.adminUserRole('usr_123'), '/admin/users/usr_123/role');
      expect(ApiConfig.adminFederationTree, '/admin/federation-tree');
      expect(ApiConfig.adminCooperatives, '/admin/cooperatives');
      expect(ApiConfig.adminWorkers, '/admin/workers');
      expect(ApiConfig.adminBookings, '/admin/bookings');
      expect(ApiConfig.adminPayments, '/admin/payments');
      expect(ApiConfig.adminDisputes, '/admin/disputes');
      expect(ApiConfig.adminResolveDispute('cmp_123'), '/admin/disputes/cmp_123/resolve');
      expect(ApiConfig.adminAuditLogs, '/admin/audit-logs');
      expect(ApiConfig.adminAnalytics, '/admin/analytics');
    });

    test('AdminProvider initializes with empty/safe state', () {
      final provider = AdminProvider();
      expect(provider.isLoading, isFalse);
      expect(provider.associationWorkers, isEmpty);
      expect(provider.associationServices, isEmpty);
      expect(provider.adminUsers, isEmpty);
      expect(provider.adminCooperatives, isEmpty);
      expect(provider.adminAllWorkers, isEmpty);
      expect(provider.adminDisputes, isEmpty);
    });
  });

  group('Phase 6: UI Authorization & Role Guard Widget Tests', () {
    testWidgets('Customer persona is blocked with 403 Access Denied screen', (tester) async {
      final auth = AuthProvider();
      auth.setCurrentUserForTesting(const User(
        id: 'usr_cust_01',
        name: 'Ananya Sharma',
        phone: '+91 98765 43210',
        email: 'ananya@example.com',
        role: UserRole.customer,
      ));

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: auth),
            ChangeNotifierProvider<AdminProvider>(create: (_) => MockAdminProvider()),
          ],
          child: const MaterialApp(
            home: AdminDashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Expect 403 Access Denied
      expect(find.text('403 — Administrative Access Denied'), findsOneWidget);
      expect(find.text('Return to Home'), findsOneWidget);
      expect(find.byIcon(Icons.gpp_bad_rounded), findsOneWidget);
    });

    testWidgets('Cooperative Association Head can access Association Console', (tester) async {
      final auth = AuthProvider();
      auth.setCurrentUserForTesting(const User(
        id: 'usr_head_01',
        name: 'Sundaramoorthy Head',
        phone: '+91 98400 11001',
        email: 'head.north@tnlabourcoop.org',
        role: UserRole.cooperativeAssociationHead,
        cooperativeId: 'coop_north_01',
        cooperativeName: 'North Chennai Labour Cooperative Society',
      ));

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: auth),
            ChangeNotifierProvider<AdminProvider>(create: (_) => MockAdminProvider()),
          ],
          child: const MaterialApp(
            home: AdminDashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Expect Association Console
      expect(find.text('North Chennai Labour Cooperative Society'), findsWidgets);
      expect(find.text('Association Head Management Console'), findsOneWidget);
      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('Workers'), findsOneWidget);
      expect(find.text('Services & Tariffs'), findsOneWidget);
      expect(find.text('Bookings & Ops'), findsOneWidget);
      expect(find.text('Disputes & Financials'), findsOneWidget);
    });

    testWidgets('Super Admin can access Apex Federation Governance Console', (tester) async {
      final auth = AuthProvider();
      auth.setCurrentUserForTesting(const User(
        id: 'usr_super_01',
        name: 'Apex Super Administrator',
        phone: '+91 98400 00001',
        email: 'superadmin@tnlabourcoop.org',
        role: UserRole.superAdmin,
      ));

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: auth),
            ChangeNotifierProvider<AdminProvider>(create: (_) => MockAdminProvider()),
          ],
          child: const MaterialApp(
            home: AdminDashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Expect Super Admin Console
      expect(find.text('State Apex Labour Federation'), findsOneWidget);
      expect(find.text('Super Administrator Platform Oversight'), findsOneWidget);
      expect(find.text('Platform Overview'), findsOneWidget);
      expect(find.text('User Directory'), findsOneWidget);
      expect(find.text('Federation Tree'), findsOneWidget);
      expect(find.text('All Workers'), findsOneWidget);
      expect(find.text('Disputes & Refunds'), findsOneWidget);
      expect(find.text('Audit Trail'), findsOneWidget);
    });
  });
}
