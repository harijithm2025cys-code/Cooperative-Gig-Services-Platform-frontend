import 'package:flutter_test/flutter_test.dart';
import 'package:cooperative_gig_services/models/assignment.dart';
import 'package:cooperative_gig_services/models/booking.dart';

void main() {
  group('Phase 3 Automatic Allocation Models & Serialization', () {
    test('BookingAssignment fromJson & toJson works correctly', () {
      final json = {
        'id': 'asgn_101',
        'booking_id': 'BK-5001',
        'worker_id': 'wrk_99',
        'status': 'ASSIGNED',
        'distance_km': 3.2,
        'matching_score': 88.5,
        'assignment_sequence': 1,
        'worker_name': 'Ramesh Electrician',
        'worker_phone': '+91 98450 11223',
        'worker_skill': 'Electrician',
        'cooperative_name': 'Koramangala Labour Cooperative',
      };

      final asgn = BookingAssignment.fromJson(json);
      expect(asgn.id, 'asgn_101');
      expect(asgn.bookingId, 'BK-5001');
      expect(asgn.workerId, 'wrk_99');
      expect(asgn.status, 'ASSIGNED');
      expect(asgn.distanceKm, 3.2);
      expect(asgn.matchingScore, 88.5);
      expect(asgn.assignmentSequence, 1);
      expect(asgn.workerName, 'Ramesh Electrician');

      final outJson = asgn.toJson();
      expect(outJson['status'], 'ASSIGNED');
      expect(outJson['matching_score'], 88.5);
    });

    test('Booking model handles multi-worker assignment list and allocation status', () {
      final bookingJson = {
        'id': 'BK-MULTI-01',
        'worker_id': 'wrk_01',
        'service_id': 'Plumbing',
        'status': 'accepted',
        'amount': 700.0,
        'required_worker_count': 2,
        'assigned_worker_count': 2,
        'allocation_status': 'ASSIGNED',
        'assignments': [
          {
            'id': 'asgn_1',
            'booking_id': 'BK-MULTI-01',
            'worker_id': 'wrk_01',
            'status': 'ASSIGNED',
            'assignment_sequence': 1,
            'distance_km': 1.5,
            'worker_name': 'Plumber 1'
          },
          {
            'id': 'asgn_2',
            'booking_id': 'BK-MULTI-01',
            'worker_id': 'wrk_02',
            'status': 'ASSIGNED',
            'assignment_sequence': 2,
            'distance_km': 2.1,
            'worker_name': 'Plumber 2'
          }
        ]
      };

      final booking = Booking.fromJson(bookingJson);
      expect(booking.requiredWorkerCount, 2);
      expect(booking.assignedWorkerCount, 2);
      expect(booking.allocationStatus, 'ASSIGNED');
      expect(booking.assignments, isNotNull);
      expect(booking.assignments!.length, 2);
      expect(booking.assignments![0].workerName, 'Plumber 1');
      expect(booking.assignments![1].workerName, 'Plumber 2');
    });

    test('MatchingAuditLog deserializes rejection reasons and distance correctly', () {
      final logJson = {
        'id': 'log_01',
        'booking_id': 'BK-100',
        'worker_id': 'wrk_rejected',
        'is_eligible': false,
        'rejection_reason': 'skill_mismatch',
        'distance_km': 12.4,
        'matching_score': 0.0
      };

      final log = MatchingAuditLog.fromJson(logJson);
      expect(log.isEligible, false);
      expect(log.rejectionReason, 'skill_mismatch');
      expect(log.distanceKm, 12.4);
    });
  });
}
