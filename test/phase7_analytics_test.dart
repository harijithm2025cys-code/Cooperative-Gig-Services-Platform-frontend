import 'package:flutter_test/flutter_test.dart';
import 'package:cooperative_gig_services/config/api_config.dart';
import 'package:cooperative_gig_services/providers/admin_provider.dart';

void main() {
  group('Phase 7 Analytics & ML Foundation Unit Tests', () {
    test('ApiConfig Phase 7 endpoints URLs are well-formed', () {
      expect(ApiConfig.analyticsPlatform, equals('/analytics/platform'));
      expect(ApiConfig.analyticsAssociation('coop_north_01'), equals('/analytics/association/coop_north_01'));
      expect(ApiConfig.analyticsServices, equals('/analytics/services'));
      expect(ApiConfig.analyticsWorkers, equals('/analytics/workers'));
      expect(ApiConfig.analyticsDemand, equals('/analytics/demand'));
      expect(ApiConfig.analyticsMatching, equals('/analytics/matching'));
      expect(ApiConfig.analyticsDataQuality, equals('/analytics/data-quality'));
      expect(ApiConfig.mlWorkerRanking, equals('/analytics/ml-dataset/worker-ranking'));
      expect(ApiConfig.mlDemandForecast, equals('/analytics/ml-dataset/demand-forecast'));
      expect(
        ApiConfig.analyticsExportCsv('worker_utilization', coopId: 'coop_north_01'),
        equals('/analytics/export/csv?type=worker_utilization&cooperative_id=coop_north_01'),
      );
    });

    test('AdminProvider initializes Phase 7 state correctly', () {
      final provider = AdminProvider();
      expect(provider.selectedDateRange, equals('last_30_days'));
      expect(provider.platformKpis, isNull);
      expect(provider.phase7AssociationAnalytics, isNull);
      expect(provider.serviceDemand, isNull);
      expect(provider.workerUtilizationList, isEmpty);
      expect(provider.matchingAnalytics, isNull);
      expect(provider.geographicDemand, isNull);
      expect(provider.dataQualityReport, isNull);
    });

    test('AdminProvider date range state updates reliably', () async {
      final provider = AdminProvider();
      expect(provider.selectedDateRange, equals('last_30_days'));

      // Changing date range updates selectedDateRange
      provider.setDateRange('today');
      expect(provider.selectedDateRange, equals('today'));

      provider.setDateRange('this_month');
      expect(provider.selectedDateRange, equals('this_month'));
    });
  });
}
