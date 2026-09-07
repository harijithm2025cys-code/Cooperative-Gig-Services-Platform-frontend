import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:cooperative_gig_services/config/api_config.dart';
import 'package:cooperative_gig_services/providers/admin_provider.dart';
import 'package:cooperative_gig_services/providers/auth_provider.dart';
import 'package:cooperative_gig_services/models/user.dart';
import 'package:cooperative_gig_services/screens/admin/admin_dashboard_screen.dart';

class MockAdminProvider extends AdminProvider {
  @override
  Future<void> fetchAssociationData({String? cooperativeId}) async {}

  @override
  Future<void> fetchSuperAdminData() async {}

  @override
  Future<void> fetchPhase7Analytics({
    String? cooperativeId,
    bool isSuperAdmin = false,
    String? startDate,
    String? endDate,
  }) async {}

  @override
  Future<void> loadAllMlData({String? cooperativeId, String district = 'Chennai North'}) async {
    // Populate in-memory demonstration state directly without HTTP calls
    setMockMlData();
  }

  void setMockMlData() {
    setMlDataForTesting(
      modelStatus: {
        'success': true,
        'status': 'active',
        'worker_ranking_loaded': true,
        'duration_model_loaded': true,
        'demand_model_loaded': true,
        'total_inferences': 48,
        'total_fallbacks': 2,
        'fallback_rate_percent': 4.2,
      },
      modelMetrics: {
        'success': true,
        'worker_ranking': {'accuracy': 0.88, 'top_1_accuracy': 0.85, 'top_3_accuracy': 0.96},
        'duration_prediction': {'mae_minutes': 12.4, 'rmse_minutes': 15.8},
        'demand_forecasting': {'wape_percent': 14.2, 'peak_accuracy': 0.89},
      },
      demandForecast: {
        'success': true,
        'model_version': 'demand-forecast-v1',
        'forecast_type': 'ML SEASONAL FORECAST',
        'is_baseline_fallback': false,
        'district': 'Chennai North',
        'forecast_horizon_days': 7,
        'confidence_score': 0.88,
        'seven_day_projections': [
          {
            'date': '2026-09-08',
            'day_of_week': 'Tuesday',
            'predicted_total_bookings': 18,
            'predicted_emergency_count': 3,
            'category_breakdown': {'Plumbing': 7, 'Electrical': 6, 'Carpentry': 3, 'Appliances': 2},
            'peak_expected_hour': 10,
            'is_high_demand_day': false,
          },
          {
            'date': '2026-09-09',
            'day_of_week': 'Wednesday',
            'predicted_total_bookings': 16,
            'predicted_emergency_count': 2,
            'category_breakdown': {'Plumbing': 6, 'Electrical': 5, 'Carpentry': 3, 'Appliances': 2},
            'peak_expected_hour': 10,
            'is_high_demand_day': false,
          },
        ],
        'busy_peak_hours': [
          {'hour': 9, 'label': '09:00 - 10:00 AM', 'demand_level': 'HIGH', 'projected_volume': 6},
          {'hour': 11, 'label': '11:00 - 12:00 PM', 'demand_level': 'PEAK', 'projected_volume': 8},
        ],
        'workforce_recommendations': [
          {
            'category': 'Plumbing',
            'district': 'Chennai North',
            'priority': 'HIGH',
            'recommendation_text': 'High demand anticipated for Plumbing. Alert +4 on-call specialists.',
          },
        ]
      },
    );
  }
}

void main() {
  group('Phase 8 ML Config & API Endpoints', () {
    test('ApiConfig defines Phase 8 ML endpoints', () {
      expect(ApiConfig.mlWorkerRankingInference, '/ml/worker-ranking');
      expect(ApiConfig.mlDurationPrediction, '/ml/duration-prediction');
      expect(ApiConfig.mlDemandForecastEndpoint, '/ml/demand-forecast');
      expect(ApiConfig.mlModelStatus, '/ml/model-status');
      expect(ApiConfig.mlModelMetrics, '/ml/model-metrics');
      expect(ApiConfig.mlRetrain, '/ml/train');
    });
  });

  group('Phase 8 AdminProvider ML State Management', () {
    test('AdminProvider initializes with empty ML state', () {
      final provider = AdminProvider();
      expect(provider.isMlLoading, false);
      expect(provider.mlDemandForecast, null);
      expect(provider.mlModelStatus, null);
      expect(provider.mlModelMetrics, null);
      expect(provider.mlDurationPrediction, null);
      expect(provider.mlError, null);
    });

    test('loadAllMlData populates demand forecast, model status, and metrics', () async {
      final provider = AdminProvider();
      await provider.loadAllMlData();

      expect(provider.isMlLoading, false);
      expect(provider.mlModelStatus, isNotNull);
      expect(provider.mlModelMetrics, isNotNull);
      expect(provider.mlDemandForecast, isNotNull);

      // Verify demand forecast structure
      final forecast = provider.mlDemandForecast!;
      expect(forecast['success'], true);
      expect(forecast['seven_day_projections'], isA<List>());
      final projections = forecast['seven_day_projections'] as List;
      expect(projections.length, 7);

      final firstDay = projections[0] as Map;
      expect(firstDay['predicted_total_bookings'], isA<num>());
      expect(firstDay['predicted_emergency_count'], isA<num>());
      expect(firstDay['category_breakdown'], isA<Map>());

      // Verify peak busy hours
      expect(forecast['busy_peak_hours'], isA<List>());
      final peakHours = forecast['busy_peak_hours'] as List;
      expect(peakHours.isNotEmpty, true);

      // Verify workforce recommendations
      expect(forecast['workforce_recommendations'], isA<List>());
      final recs = forecast['workforce_recommendations'] as List;
      expect(recs.isNotEmpty, true);
    });

    test('predictServiceDuration computes realistic durations with emergency sensitivity', () async {
      final provider = AdminProvider();
      
      // Standard service duration
      final normalRes = await provider.predictServiceDuration(
        serviceName: 'Plumbing Pipe Repair',
        category: 'plumbing',
        isEmergency: false,
      );
      expect(normalRes, isNotNull);
      expect(normalRes!['prediction']['predicted_duration_minutes'], greaterThanOrEqualTo(60.0));

      // Emergency service duration
      final emergRes = await provider.predictServiceDuration(
        serviceName: 'Emergency Electrical Repair',
        category: 'electrical',
        isEmergency: true,
      );
      expect(emergRes, isNotNull);
      expect(emergRes!['prediction']['predicted_duration_minutes'], lessThan(60.0));
      expect(emergRes['prediction']['is_fallback'], false);
    });
  });

  group('Phase 8 Admin Dashboard Widget Integration', () {
    testWidgets('Renders ML AI & Forecasting Dashboard Tab for Association Head', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final authProvider = AuthProvider();
      authProvider.setCurrentUserForTesting(
        const User(
          id: 'head_01',
          name: 'Ramesh Association Head',
          email: 'head@coop.org',
          phone: '+91 98765 43210',
          role: UserRole.cooperativeAssociationHead,
          cooperativeId: 'coop_north_01',
          cooperativeName: 'North Chennai Labour Cooperative Society',
        ),
      );

      final adminProvider = MockAdminProvider();
      adminProvider.setMockMlData();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
            ChangeNotifierProvider<AdminProvider>.value(value: adminProvider),
          ],
          child: const MaterialApp(
            home: AdminDashboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find and switch to AI & Forecasting Tab
      final aiTab = find.text('AI & Forecasting');
      expect(aiTab, findsOneWidget);
      await tester.tap(aiTab);
      await tester.pumpAndSettle();

      // Verify AI & Forecasting Header and Telemetry
      expect(find.text('AI / ML Intelligence Engine'), findsOneWidget);
      expect(find.text('ONLINE'), findsOneWidget);
      expect(find.text('PREDICTED (ML)'), findsOneWidget);
      expect(find.text('Peak Busy Hours & Capacity Forecast'), findsOneWidget);
      expect(find.text('Intelligent Workforce Recommendations'), findsOneWidget);
      expect(find.text('Deterministic Hybrid Matching Formula'), findsOneWidget);
    });
  });
}
