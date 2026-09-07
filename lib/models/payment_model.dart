class RazorpayOrderModel {
  final String orderId;
  final String keyId;
  final double amount;
  final String currency;
  final String bookingId;
  final String? customerName;
  final String? customerPhone;
  final String? customerEmail;
  final String? serviceName;

  double get amountInRupees => amount;
  int get amountInPaise => (amount * 100).toInt();

  const RazorpayOrderModel({
    required this.orderId,
    this.keyId = '',
    double? amount,
    int? amountInPaise,
    this.currency = 'INR',
    required this.bookingId,
    this.customerName,
    this.customerPhone,
    this.customerEmail,
    this.serviceName,
  }) : amount = amount ?? (amountInPaise != null ? amountInPaise / 100.0 : 0.0);

  factory RazorpayOrderModel.fromJson(Map<String, dynamic> json) {
    double parsedAmount = 0.0;
    if (json['amount'] != null) {
      if (json['amount'] is int) {
        final intVal = json['amount'] as int;
        // In Razorpay orders, integer amounts >= 100 are typically in paise
        parsedAmount = (intVal >= 100) ? intVal / 100.0 : intVal.toDouble();
      } else if (json['amount'] is num) {
        parsedAmount = (json['amount'] as num).toDouble();
      }
    }
    return RazorpayOrderModel(
      orderId: json['order_id']?.toString() ?? '',
      keyId: json['key_id']?.toString() ?? '',
      amount: parsedAmount,
      currency: json['currency']?.toString() ?? 'INR',
      bookingId: json['booking_id']?.toString() ?? '',
      customerName: json['customer_name']?.toString(),
      customerPhone: json['customer_phone']?.toString(),
      customerEmail: json['customer_email']?.toString(),
      serviceName: json['service_name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'key_id': keyId,
      'amount': amountInPaise,
      'currency': currency,
      'booking_id': bookingId,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'customer_email': customerEmail,
      'service_name': serviceName,
    };
  }
}

class PaymentDetailModel {
  final String id;
  final String bookingId;
  final String? razorpayOrderId;
  final String? razorpayPaymentId;
  final double amount;
  final String currency;
  final String status;
  final String settlementStatus;
  final String paymentMethod;
  final bool signatureVerified;
  final DateTime? paidAt;

  const PaymentDetailModel({
    required this.id,
    required this.bookingId,
    this.razorpayOrderId,
    this.razorpayPaymentId,
    required this.amount,
    this.currency = 'INR',
    required this.status,
    this.settlementStatus = 'PENDING',
    this.paymentMethod = 'upi',
    this.signatureVerified = false,
    this.paidAt,
  });

  PaymentDetailModel copyWith({
    String? id,
    String? bookingId,
    String? razorpayOrderId,
    String? razorpayPaymentId,
    double? amount,
    String? currency,
    String? status,
    String? settlementStatus,
    String? paymentMethod,
    bool? signatureVerified,
    DateTime? paidAt,
  }) {
    return PaymentDetailModel(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      razorpayOrderId: razorpayOrderId ?? this.razorpayOrderId,
      razorpayPaymentId: razorpayPaymentId ?? this.razorpayPaymentId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      settlementStatus: settlementStatus ?? this.settlementStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      signatureVerified: signatureVerified ?? this.signatureVerified,
      paidAt: paidAt ?? this.paidAt,
    );
  }

  factory PaymentDetailModel.fromJson(Map<String, dynamic> json) {
    return PaymentDetailModel(
      id: json['id']?.toString() ?? '',
      bookingId: json['booking_id']?.toString() ?? '',
      razorpayOrderId: json['razorpay_order_id']?.toString(),
      razorpayPaymentId: json['razorpay_payment_id']?.toString(),
      amount: (json['amount'] is num) ? (json['amount'] as num).toDouble() : 0.0,
      currency: json['currency']?.toString() ?? 'INR',
      status: json['status']?.toString() ?? 'CREATED',
      settlementStatus: json['settlement_status']?.toString() ?? 'PENDING',
      paymentMethod: json['payment_method']?.toString() ?? 'upi',
      signatureVerified: json['signature_verified'] == true,
      paidAt: json['paid_at'] != null ? DateTime.tryParse(json['paid_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'razorpay_order_id': razorpayOrderId,
      'razorpay_payment_id': razorpayPaymentId,
      'amount': amount,
      'currency': currency,
      'status': status,
      'settlement_status': settlementStatus,
      'payment_method': paymentMethod,
      'signature_verified': signatureVerified,
      'paid_at': paidAt?.toIso8601String(),
    };
  }
}
