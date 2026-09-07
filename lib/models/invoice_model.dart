class InvoiceModel {
  final String id;
  final String bookingId;
  final String invoiceNumber;
  final String? customerName;
  final String? cooperativeName;
  final String? cooperativeGstin;
  final String serviceName;
  final DateTime serviceDate;
  final int workerCount;
  final double unitPrice;
  final double amount; // Base taxable amount
  final double taxAmount; // GST
  final double totalAmount;
  final String currency;
  final String status;
  final String? paymentId;
  final String? pdfUrl;
  final String sacCode;
  final DateTime issuedAt;

  // Compatibility aliases
  String get invoiceStatus => status;
  DateTime get generatedAt => issuedAt;

  InvoiceModel({
    required this.id,
    required this.bookingId,
    required this.invoiceNumber,
    this.customerName,
    this.cooperativeName,
    this.cooperativeGstin = '29ABCDE1234F1Z5',
    this.serviceName = 'Household Cooperative Service',
    DateTime? serviceDate,
    this.workerCount = 1,
    double? unitPrice,
    double? amount,
    double? taxAmount,
    required this.totalAmount,
    this.currency = 'INR',
    this.status = 'ISSUED',
    this.paymentId,
    this.pdfUrl,
    this.sacCode = '998713',
    DateTime? issuedAt,
  })  : amount = amount ?? (unitPrice != null ? unitPrice * (workerCount > 0 ? workerCount : 1) : totalAmount / 1.18),
        taxAmount = taxAmount ?? (totalAmount - (amount ?? (totalAmount / 1.18))),
        unitPrice = unitPrice ?? (amount ?? (totalAmount / 1.18)),
        serviceDate = serviceDate ?? (issuedAt ?? DateTime.now()),
        issuedAt = issuedAt ?? DateTime.now();

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    final double total = (json['total_amount'] is num)
        ? (json['total_amount'] as num).toDouble()
        : (json['amount'] is num ? (json['amount'] as num).toDouble() : 0.0);
    final double base = (json['amount'] is num && json['total_amount'] != null)
        ? (json['amount'] as num).toDouble()
        : (total / 1.18);
    final double tax = (json['tax_amount'] is num)
        ? (json['tax_amount'] as num).toDouble()
        : (total - base);

    final issued = json['issued_at'] != null
        ? DateTime.tryParse(json['issued_at'].toString()) ?? DateTime.now()
        : (json['generated_at'] != null
            ? DateTime.tryParse(json['generated_at'].toString()) ?? DateTime.now()
            : DateTime.now());

    return InvoiceModel(
      id: json['id']?.toString() ?? '',
      bookingId: json['booking_id']?.toString() ?? '',
      invoiceNumber: json['invoice_number']?.toString() ?? 'INV-UNKNOWN',
      customerName: json['customer_name']?.toString() ?? 'Valued Customer',
      cooperativeName: json['cooperative_name']?.toString() ?? 'Labour Cooperative Society',
      cooperativeGstin: json['cooperative_gstin']?.toString() ?? '29ABCDE1234F1Z5',
      serviceName: json['service_name']?.toString() ?? 'Household Service',
      serviceDate: json['service_date'] != null
          ? DateTime.tryParse(json['service_date'].toString()) ?? issued
          : issued,
      workerCount: (json['worker_count'] is num) ? (json['worker_count'] as num).toInt() : 1,
      amount: base,
      taxAmount: tax,
      totalAmount: total,
      currency: json['currency']?.toString() ?? 'INR',
      status: json['status']?.toString() ?? (json['invoice_status']?.toString() ?? 'ISSUED'),
      paymentId: json['payment_id']?.toString(),
      pdfUrl: json['pdf_url']?.toString(),
      sacCode: json['sac_code']?.toString() ?? '998713',
      issuedAt: issued,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'invoice_number': invoiceNumber,
      'customer_name': customerName,
      'cooperative_name': cooperativeName,
      'cooperative_gstin': cooperativeGstin,
      'service_name': serviceName,
      'service_date': serviceDate.toIso8601String(),
      'worker_count': workerCount,
      'unit_price': unitPrice,
      'amount': amount,
      'tax_amount': taxAmount,
      'total_amount': totalAmount,
      'currency': currency,
      'status': status,
      'payment_id': paymentId,
      'pdf_url': pdfUrl,
      'sac_code': sacCode,
      'issued_at': issuedAt.toIso8601String(),
    };
  }
}
