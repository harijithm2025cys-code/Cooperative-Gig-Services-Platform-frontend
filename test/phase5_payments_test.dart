import 'package:flutter_test/flutter_test.dart';
import 'package:cooperative_gig_services/models/booking.dart';
import 'package:cooperative_gig_services/models/payment_model.dart';
import 'package:cooperative_gig_services/models/invoice_model.dart';
import 'package:cooperative_gig_services/models/complaint_model.dart';
import 'package:cooperative_gig_services/config/api_config.dart';
import 'package:cooperative_gig_services/services/razorpay_service.dart';

void main() {
  group('Phase 5 Payments, Invoices, OTP & Dispute Models', () {
    test('RazorpayOrderModel correctly parses and computes rupees', () {
      final json = {
        'order_id': 'order_1234567890',
        'amount': 42000, // in paise
        'currency': 'INR',
        'booking_id': 'BK-5001',
      };

      final order = RazorpayOrderModel.fromJson(json);
      expect(order.orderId, 'order_1234567890');
      expect(order.amountInPaise, 42000);
      expect(order.amountInRupees, 420.0);
      expect(order.currency, 'INR');
      expect(order.bookingId, 'BK-5001');

      final out = order.toJson();
      expect(out['order_id'], 'order_1234567890');
      expect(out['amount'], 42000);
    });

    test('PaymentDetailModel handles CAPTURED payment and settlement status', () {
      final json = {
        'id': 'pay_9876543210',
        'booking_id': 'BK-5001',
        'razorpay_order_id': 'order_1234567890',
        'razorpay_payment_id': 'pay_9876543210',
        'amount': 420.0,
        'currency': 'INR',
        'status': 'CAPTURED',
        'settlement_status': 'PENDING',
        'payment_method': 'upi',
        'created_at': '2026-09-07T22:00:00Z',
      };

      final payment = PaymentDetailModel.fromJson(json);
      expect(payment.id, 'pay_9876543210');
      expect(payment.bookingId, 'BK-5001');
      expect(payment.status, 'CAPTURED');
      expect(payment.settlementStatus, 'PENDING');
      expect(payment.amount, 420.0);
      expect(payment.paymentMethod, 'upi');

      // Test copyWith transition to ELIGIBLE
      final eligiblePayment = payment.copyWith(settlementStatus: 'ELIGIBLE');
      expect(eligiblePayment.settlementStatus, 'ELIGIBLE');
      expect(eligiblePayment.status, 'CAPTURED');
    });

    test('InvoiceModel parses tax invoice breakdown and GST calculations', () {
      final json = {
        'id': 'inv_5001',
        'invoice_number': 'INV-20260907-0042',
        'booking_id': 'BK-5001',
        'amount': 420.0,
        'tax_amount': 75.6, // 18% GST
        'total_amount': 495.6,
        'sac_code': '998713',
        'issued_at': '2026-09-07T22:15:00Z',
        'status': 'ISSUED',
        'pdf_url': null,
        'cooperative_name': 'Labour Guild Cooperative Society',
        'cooperative_gstin': '29ABCDE1234F1Z5',
      };

      final invoice = InvoiceModel.fromJson(json);
      expect(invoice.invoiceNumber, 'INV-20260907-0042');
      expect(invoice.amount, 420.0);
      expect(invoice.taxAmount, 75.6);
      expect(invoice.totalAmount, 495.6);
      expect(invoice.sacCode, '998713');
      expect(invoice.cooperativeGstin, '29ABCDE1234F1Z5');
      expect(invoice.status, 'ISSUED');
    });

    test('ComplaintModel lifecycle correctly parses open and resolved disputes', () {
      final json = {
        'id': 'cmp_7701',
        'booking_id': 'BK-5001',
        'complainant_id': 'usr_cust_01',
        'category': 'Service incomplete',
        'description': 'Outdoor AC unit was not serviced.',
        'status': 'open',
        'created_at': '2026-09-07T22:10:00Z',
        'cooperative_id': 'coop_blr_01',
      };

      final cmp = ComplaintModel.fromJson(json);
      expect(cmp.id, 'cmp_7701');
      expect(cmp.category, 'Service incomplete');
      expect(cmp.status, ComplaintStatus.open);

      final resolvedCmp = cmp.copyWith(
        status: ComplaintStatus.resolved,
        resolutionNotes: 'Technician revisited and completed outdoor coil cleaning.',
        resolvedAt: DateTime.now(),
      );
      expect(resolvedCmp.status, ComplaintStatus.resolved);
      expect(resolvedCmp.resolutionNotes, contains('Technician revisited'));
    });

    test('Booking model handles Phase 5 settlement status, invoiceId, and completion states', () {
      final bookingJson = {
        'id': 'BK-5001',
        'worker_id': 'wrk_01',
        'service_id': 'AC Technician',
        'status': 'customer_confirmation_pending',
        'amount': 420.0,
        'payment_status': 'captured',
        'settlement_status': 'PENDING',
        'invoice_id': null,
      };

      final b = Booking.fromJson(bookingJson);
      expect(b.status, BookingStatus.customerConfirmationPending);
      expect(b.paymentStatus, PaymentStatus.captured);
      expect(b.settlementStatus, 'PENDING');
      expect(b.invoiceId, isNull);

      final confirmed = b.copyWith(
        status: BookingStatus.customerConfirmed,
        settlementStatus: 'ELIGIBLE',
        invoiceId: 'INV-20260907-0042',
      );
      expect(confirmed.status, BookingStatus.customerConfirmed);
      expect(confirmed.settlementStatus, 'ELIGIBLE');
      expect(confirmed.invoiceId, 'INV-20260907-0042');
    });

    test('ApiConfig provides all Phase 5 payment, invoice, and dispute endpoints', () {
      expect(ApiConfig.createPaymentOrder, '/payments/create-order');
      expect(ApiConfig.verifyPayment, '/payments/verify');
      expect(ApiConfig.paymentDetail('pay_001'), '/payments/pay_001');
      expect(ApiConfig.refundPayment('pay_001'), '/payments/pay_001/refund');
      expect(ApiConfig.invoiceByBooking('BK-001'), '/invoices/booking/BK-001');
      expect(ApiConfig.invoiceDetail('inv_001'), '/invoices/inv_001');
      expect(ApiConfig.invoiceDownload('inv_001'), '/invoices/inv_001/download');
      expect(ApiConfig.bookingCompletionOtp('BK-001'), '/bookings/BK-001/completion-otp');
      expect(ApiConfig.workerVerifyCompletionOtp('wrk_01'), '/workers/wrk_01/verify-completion-otp');
      expect(ApiConfig.complaints, '/complaints/');
      expect(ApiConfig.cooperativeComplaints('coop_01'), '/complaints/cooperative/coop_01');
      expect(ApiConfig.resolveComplaint('cmp_01'), '/complaints/cmp_01/resolve');
    });

    test('RazorpayPaymentResponse creates valid verification payload', () {
      final resp = RazorpayPaymentResponse(
        razorpayOrderId: 'order_test_999',
        razorpayPaymentId: 'pay_test_888',
        razorpaySignature: 'sig_test_777',
        paymentMethod: 'upi',
      );

      final json = resp.toJson();
      expect(json['razorpay_order_id'], 'order_test_999');
      expect(json['razorpay_payment_id'], 'pay_test_888');
      expect(json['razorpay_signature'], 'sig_test_777');
      expect(json['payment_method'], 'upi');
    });
  });
}
