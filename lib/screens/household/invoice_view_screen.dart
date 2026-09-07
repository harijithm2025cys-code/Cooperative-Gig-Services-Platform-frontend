import 'package:flutter/material.dart';
import '../../models/invoice_model.dart';
import '../../utils/app_colors.dart';

class InvoiceViewScreen extends StatelessWidget {
  final InvoiceModel invoice;
  final String? customerName;
  final String? customerPhone;
  final String? customerAddress;

  const InvoiceViewScreen({
    super.key,
    required this.invoice,
    this.customerName,
    this.customerPhone,
    this.customerAddress,
  });

  @override
  Widget build(BuildContext context) {
    final cgst = invoice.taxAmount / 2;
    final sgst = invoice.taxAmount / 2;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('Tax Invoice & Receipt', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.print_outlined, color: AppColors.primary),
            tooltip: 'Print / Save Receipt',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Downloading invoice ${invoice.invoiceNumber} PDF receipt…'),
                  backgroundColor: AppColors.statusCompleted,
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Official Tax Receipt Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cooperative Header
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.account_balance_rounded, color: AppColors.primaryDark, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                invoice.cooperativeName ?? 'Labour Guild Cooperative Society',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'GSTIN: ${invoice.cooperativeGstin ?? '29ABCDE1234F1Z5'} • SAC: ${invoice.sacCode}',
                                style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                              ),
                              const Text(
                                'Registered Labour Cooperative Federation',
                                style: TextStyle(fontSize: 11, color: AppColors.primaryDark, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32, color: AppColors.border),

                    // Invoice Metas
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('INVOICE NUMBER', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.textTertiary, letterSpacing: 0.5)),
                            const SizedBox(height: 3),
                            Text(invoice.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: AppColors.textPrimary)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('ISSUE DATE', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.textTertiary, letterSpacing: 0.5)),
                            const SizedBox(height: 3),
                            Text(
                              '${invoice.issuedAt.day.toString().padLeft(2, '0')}/${invoice.issuedAt.month.toString().padLeft(2, '0')}/${invoice.issuedAt.year}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('BOOKING ID', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.textTertiary, letterSpacing: 0.5)),
                            const SizedBox(height: 3),
                            Text(invoice.bookingId, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textSecondary)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.statusCompletedBg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.statusCompleted.withValues(alpha: 0.3)),
                          ),
                          child: const Text('PAID & SETTLED', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.statusCompleted)),
                        ),
                      ],
                    ),
                    const Divider(height: 32, color: AppColors.border),

                    // Bill To
                    const Text('BILL TO (CUSTOMER)', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.textTertiary, letterSpacing: 0.5)),
                    const SizedBox(height: 4),
                    Text(customerName ?? 'Customer', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: AppColors.textPrimary)),
                    if (customerPhone != null) ...[
                      const SizedBox(height: 2),
                      Text(customerPhone!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                    if (customerAddress != null) ...[
                      const SizedBox(height: 2),
                      Text(customerAddress!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                    const Divider(height: 32, color: AppColors.border),

                    // Line Items
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('DESCRIPTION', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.textTertiary)),
                        Text('AMOUNT', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.textTertiary)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Cooperative Service Charge', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5, color: AppColors.textPrimary)),
                              Text('SAC code: ${invoice.sacCode}', style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                            ],
                          ),
                        ),
                        Text('₹${invoice.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: AppColors.textPrimary)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Divider(color: Color(0xFFF1F5F9)),
                    const SizedBox(height: 6),

                    // Tax breakdown
                    _buildTaxRow('Base Taxable Value:', '₹${invoice.amount.toStringAsFixed(2)}'),
                    const SizedBox(height: 6),
                    _buildTaxRow('CGST (9.0%):', '₹${cgst.toStringAsFixed(2)}'),
                    const SizedBox(height: 6),
                    _buildTaxRow('SGST (9.0%):', '₹${sgst.toStringAsFixed(2)}'),
                    const Divider(height: 24, color: AppColors.border),

                    // Total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Amount Paid', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
                        Text(
                          '₹${invoice.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: AppColors.primaryDark),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Compliance notice
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.shield_outlined, size: 16, color: AppColors.statusCompleted),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'This is a digitally generated tax invoice for services rendered under Labour Cooperative Bylaws.',
                              style: TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.check_rounded, size: 20),
                  label: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5)),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaxRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
        Text(value, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      ],
    );
  }
}
