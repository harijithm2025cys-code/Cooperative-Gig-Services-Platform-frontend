import 'package:flutter_test/flutter_test.dart';
import 'package:cooperative_gig_services/models/booking.dart';
import 'package:cooperative_gig_services/models/notification_model.dart';
import 'package:cooperative_gig_services/models/assignment.dart';

void main() {
  group('Phase 4 Realtime Operations & Emergency Models', () {
    test('AppNotification fromJson and toJson serialization works', () {
      final json = {
        'id': 'notif_001',
        'user_id': 'usr_cust_01',
        'title': 'Specialist En Route',
        'body': 'Worker Ramesh is on the way. ETA: ~12 mins.',
        'notification_type': 'WORKER_ON_THE_WAY',
        'booking_id': 'BK-4001',
        'is_read': false,
        'metadata': {'eta_minutes': 12, 'distance_km': 3.4},
        'created_at': '2026-09-07T21:45:00Z',
      };

      final notif = AppNotification.fromJson(json);
      expect(notif.id, 'notif_001');
      expect(notif.userId, 'usr_cust_01');
      expect(notif.title, 'Specialist En Route');
      expect(notif.notificationType, 'WORKER_ON_THE_WAY');
      expect(notif.bookingId, 'BK-4001');
      expect(notif.isRead, isFalse);
      expect(notif.metadata['eta_minutes'], 12);

      final out = notif.toJson();
      expect(out['id'], 'notif_001');
      expect(out['notification_type'], 'WORKER_ON_THE_WAY');
      expect(out['is_read'], isFalse);

      final readNotif = notif.copyWith(isRead: true);
      expect(readNotif.isRead, isTrue);
      expect(readNotif.id, notif.id);
    });

    test('Booking model handles Phase 4 ETA, Emergency, and Cancellation fields', () {
      final bookingJson = {
        'id': 'BK-EMG-999',
        'worker_id': 'wrk_01',
        'service_id': 'Electrician',
        'status': 'on_the_way',
        'amount': 625.0,
        'is_emergency': true,
        'worker_live_lat': 12.9730,
        'worker_live_lng': 77.5950,
        'eta_formatted': '~8 mins (approx. 2.1 km @ 25 km/h)',
        'cancellation_reason': null,
      };

      final b = Booking.fromJson(bookingJson);
      expect(b.id, 'BK-EMG-999');
      expect(b.isEmergency, isTrue);
      expect(b.workerLiveLat, 12.9730);
      expect(b.workerLiveLng, 77.5950);
      expect(b.etaFormatted, contains('~8 mins'));
      expect(b.cancellationReason, isNull);

      final cancelledBooking = b.copyWith(
        status: BookingStatus.cancelled,
        cancellationReason: 'Emergency resolved by building maintenance',
      );
      expect(cancelledBooking.status, BookingStatus.cancelled);
      expect(cancelledBooking.cancellationReason, 'Emergency resolved by building maintenance');

      final serialized = cancelledBooking.toJson();
      expect(serialized['is_emergency'], isTrue);
      expect(serialized['eta_formatted'], contains('~8 mins'));
      expect(serialized['cancellation_reason'], 'Emergency resolved by building maintenance');
    });

    test('BookingAssignment lifecycle transitions handle ON_THE_WAY and ARRIVED', () {
      final asgnJson = {
        'id': 'asgn_phase4',
        'booking_id': 'BK-EMG-999',
        'worker_id': 'wrk_01',
        'status': 'ON_THE_WAY',
        'worker_name': 'Ramesh Kumar',
        'distance_km': 1.8,
      };

      final asgn = BookingAssignment.fromJson(asgnJson);
      expect(asgn.status, 'ON_THE_WAY');
      expect(asgn.distanceKm, 1.8);

      final updatedAsgn = asgn.copyWith(status: 'ARRIVED');
      expect(updatedAsgn.status, 'ARRIVED');
      expect(updatedAsgn.workerName, 'Ramesh Kumar');
    });
  });
}
