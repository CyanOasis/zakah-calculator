import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:zakat/l10n/app_localizations.dart';
import '../providers/zakat_provider.dart';

class ZakatReportScreen extends StatefulWidget {
  final Map<String, dynamic>? calculationData; // Optional historical entry

  const ZakatReportScreen({super.key, this.calculationData});

  @override
  State<ZakatReportScreen> createState() => _ZakatReportScreenState();
}

class _ZakatReportScreenState extends State<ZakatReportScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ZakatProvider>();

    // Load data from historical map OR from live provider session
    final double totalAssets = widget.calculationData != null
        ? (widget.calculationData!['total_assets'] as num?)?.toDouble() ?? 0.0
        : provider.totalAssets;

    final double totalLiabilities = widget.calculationData != null
        ? (widget.calculationData!['total_liabilities'] as num?)?.toDouble() ?? 0.0
        : provider.debts;

    final double zakatDue = widget.calculationData != null
        ? (widget.calculationData!['zakat_due'] as num?)?.toDouble() ?? 0.0
        : provider.zakatDue;

    final String currency = widget.calculationData != null
        ? widget.calculationData!['currency'] as String? ?? 'USD'
        : provider.selectedCountry.currency;

    final String calculationDate = widget.calculationData != null
        ? widget.calculationData!['calculation_date'] as String? ?? ''
        : '';

    final formatter = NumberFormat.currency(symbol: '$currency ');

    final formattedDate = calculationDate.isNotEmpty
        ? DateFormat.yMMMd().add_jm().format(DateTime.parse(calculationDate))
        : DateFormat.yMMMd().add_jm().format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      appBar: AppBar(
        title: const Text('Zakat Report', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF0A462C),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Summary Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                decoration: const BoxDecoration(
                  color: Color(0xFF0A462C),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Zakat Due Summary ($formattedDate)',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      formatter.format(zakatDue),
                      style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _summaryLabel('Total Assets', formatter.format(totalAssets)),
                        _summaryLabel('Liabilities', formatter.format(totalLiabilities)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 60),

              // Actions panel
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _generateAndSharePDF(zakatDue, totalAssets, totalLiabilities, currency, formattedDate),
                      icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                      label: const Text('Export & Download PDF Report', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0E6451),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => _shareTextReport(zakatDue, totalAssets, totalLiabilities, formatter, formattedDate),
                      icon: const Icon(Icons.share_rounded, color: Color(0xFF0E6451)),
                      label: const Text('Share Text Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0E6451),
                        side: const BorderSide(color: Color(0xFF0E6451), width: 1.5),
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryLabel(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }

  void _shareTextReport(
      double zakatDue, double totalAssets, double totalLiabilities, NumberFormat formatter, String date) {
    final buffer = StringBuffer();
    buffer.writeln('🕌 ZAKAT CALCULATION REPORT');
    buffer.writeln('Date: $date');
    buffer.writeln('-----------------------------------');
    buffer.writeln('Total Assets: ${formatter.format(totalAssets)}');
    buffer.writeln('Total Liabilities: ${formatter.format(totalLiabilities)}');
    buffer.writeln('Net Wealth: ${formatter.format(totalAssets - totalLiabilities)}');
    buffer.writeln('Zakat Due (2.5%): ${formatter.format(zakatDue)}');
    buffer.writeln('-----------------------------------');
    buffer.writeln('Calculated using Al Raj Zakah App.');

    Share.share(buffer.toString(), subject: 'Zakat Report - $date');
  }

  Future<void> _generateAndSharePDF(
      double zakatDue, double totalAssets, double totalLiabilities, String currency, String date) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('ZAKAT REPORT', style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold, color: PdfColors.teal800)),
                    pw.Text('Date: $date', style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700)),
                  ],
                ),
                pw.Divider(thickness: 1.5, color: PdfColors.teal800),
                pw.SizedBox(height: 24),
                pw.Text('Calculation Breakdown', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900)),
                pw.SizedBox(height: 12),
                _pdfSummaryRow('Total Calculated Assets', '$currency ${totalAssets.toStringAsFixed(2)}'),
                _pdfSummaryRow('Total Deductible Liabilities', '$currency ${totalLiabilities.toStringAsFixed(2)}'),
                pw.Divider(thickness: 0.5, color: PdfColors.grey400),
                _pdfSummaryRow('Net Zakat-Eligible Wealth', '$currency ${(totalAssets - totalLiabilities).toStringAsFixed(2)}'),
                _pdfSummaryRow('Zakat Due (2.5%)', '$currency ${zakatDue.toStringAsFixed(2)}', isBold: true),
                pw.Spacer(),
                pw.Align(
                  alignment: pw.Alignment.center,
                  child: pw.Text('May Allah accept your purification of wealth. Ameen.', style: pw.TextStyle(fontSize: 12, fontStyle: pw.FontStyle.italic, color: PdfColors.teal800)),
                ),
              ],
            ),
          );
        },
      ),
    );

    if (kIsWeb) {
      final bytes = await pdf.save();
      final blob = XFile.fromData(bytes, mimeType: 'application/pdf', name: 'Zakat_Report.pdf');
      await Share.shareXFiles([blob], text: 'My Zakat Report');
    } else {
      final bytes = await pdf.save();
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/Zakat_Report.pdf');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles([XFile(file.path)], text: 'My Zakat Report');
    }
  }

  pw.Widget _pdfSummaryRow(String label, String val, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 6),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal, fontSize: 12)),
          pw.Text(val, style: pw.TextStyle(fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal, fontSize: 12, color: isBold ? PdfColors.teal900 : PdfColors.black)),
        ],
      ),
    );
  }
}
