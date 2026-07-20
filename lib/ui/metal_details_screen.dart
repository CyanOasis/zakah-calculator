import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:zakat/l10n/app_localizations.dart';
import '../providers/zakat_provider.dart';
import 'widgets/custom_widgets.dart';

class MetalDetailsScreen extends StatefulWidget {
  final bool isGold;

  const MetalDetailsScreen({super.key, required this.isGold});

  @override
  State<MetalDetailsScreen> createState() => _MetalDetailsScreenState();
}

class _MetalDetailsScreenState extends State<MetalDetailsScreen> {
  int _selectedDaysRange = 7; // 7 or 30 days
  int? _hoveredIndex;
  Offset? _hoverPosition;
  String? _activeUnit;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ZakatProvider>();

    // Initialize unit based on country standard if not yet set
    _activeUnit ??= provider.selectedCountry.weightUnit;

    final title = widget.isGold
        ? AppLocalizations.of(context)!.gold_details
        : AppLocalizations.of(context)!.silver_details;
    
    double conversionFactor = 1.0;
    String unitLabel = 'g';
    if (_activeUnit == 'bhori') {
      conversionFactor = 11.6638;
      unitLabel = 'vori';
    } else if (_activeUnit == 'oz') {
      conversionFactor = 31.1035;
      unitLabel = 'oz';
    }

    final currentPrice = (widget.isGold
        ? provider.effectiveGoldPricePerGram
        : provider.effectiveSilverPricePerGram) * conversionFactor;

    final changePercent = widget.isGold
        ? provider.goldChangePercent
        : provider.silverChangePercent;

    final trendHistory = widget.isGold
        ? provider.goldTrendHistory
        : provider.silverTrendHistory;

    // Convert history prices based on unit
    final convertedHistory = trendHistory.map((val) => val * conversionFactor).toList();

    // Filter history based on range
    final displayHistory = convertedHistory.length > _selectedDaysRange
        ? convertedHistory.sublist(convertedHistory.length - _selectedDaysRange)
        : convertedHistory;

    final currencySymbol = provider.selectedCountry.currency;
    final formatter = NumberFormat.currency(symbol: '$currencySymbol ', decimalDigits: 2);
    final percentSign = changePercent >= 0 ? '+' : '';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF0A462C),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: SingleChildScrollView(
          primary: false,
          child: Column(
            children: [
            // Header panel showing current rate
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              decoration: const BoxDecoration(
                color: Color(0xFF0A462C),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.current_price,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        formatter.format(currentPrice),
                        style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '/ $unitLabel',
                        style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 15),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        changePercent >= 0 ? Icons.trending_up : Icons.trending_down,
                        color: changePercent >= 0 ? const Color(0xFF8CE3CF) : const Color(0xFFFFB4B4),
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$percentSign${changePercent.toStringAsFixed(2)}%',
                        style: TextStyle(
                          color: changePercent >= 0 ? const Color(0xFF8CE3CF) : const Color(0xFFFFB4B4),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Unit Switcher Panel
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: ProfessionalCard(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                borderRadius: 16,
                child: Row(
                  children: [
                    const Icon(Icons.scale_outlined, color: Color(0xFF0E6451), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        provider.selectedLanguageCode == 'bn'
                            ? 'একক নির্বাচন করুন'
                            : (provider.selectedLanguageCode == 'tr'
                                ? 'Birim Seçin'
                                : 'Select Unit'),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF2C3E35)),
                      ),
                    ),
                    Row(
                      children: [
                        _buildUnitTab('g', AppLocalizations.of(context)!.unit_label_gram),
                        const SizedBox(width: 6),
                        _buildUnitTab('bhori', AppLocalizations.of(context)!.unit_label_bhori),
                        const SizedBox(width: 6),
                        _buildUnitTab('oz', AppLocalizations.of(context)!.unit_label_ounce),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Interactive Chart Card
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ProfessionalCard(
                padding: const EdgeInsets.all(16),
                borderRadius: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.price_trend,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2C3E35)),
                        ),
                        // Days toggle switches
                        Row(
                          children: [
                            _buildRangeButton(7),
                            const SizedBox(width: 8),
                            _buildRangeButton(30),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // The actual interactive chart canvas
                    SizedBox(
                      height: 180,
                      width: double.infinity,
                      child: displayHistory.length < 2
                          ? const Center(child: Text('Insufficient historical data'))
                          : GestureDetector(
                              onPanDown: (details) => _updateHoverState(details.localPosition, displayHistory),
                              onPanUpdate: (details) => _updateHoverState(details.localPosition, displayHistory),
                              onPanEnd: (_) => setState(() {
                                _hoveredIndex = null;
                                _hoverPosition = null;
                              }),
                              onTapDown: (details) => _updateHoverState(details.localPosition, displayHistory),
                              onTapUp: (_) => setState(() {
                                _hoveredIndex = null;
                                _hoverPosition = null;
                              }),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  CustomPaint(
                                    size: Size.infinite,
                                    painter: InteractiveChartPainter(
                                      points: displayHistory,
                                      hoveredIndex: _hoveredIndex,
                                    ),
                                  ),
                                  if (_hoveredIndex != null && _hoverPosition != null && _hoveredIndex! < displayHistory.length)
                                    Positioned(
                                      left: _hoverPosition!.dx - 55,
                                      top: _hoverPosition!.dy - 55,
                                      child: Container(
                                        width: 110,
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF0E6451),
                                          borderRadius: BorderRadius.circular(8),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            )
                                          ],
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              formatter.format(displayHistory[_hoveredIndex!]),
                                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              _getDateLabel(_hoveredIndex!, _selectedDaysRange),
                                              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 9),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),

            // Purity / Karat breakdown list
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.isGold
                        ? AppLocalizations.of(context)!.karat_breakdown
                        : AppLocalizations.of(context)!.silver_purity_breakdown,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2C3E35)),
                  ),
                  const SizedBox(height: 10),
                  if (widget.isGold) ...[
                    _buildKaratRow('24K (Pure Gold)', provider.effectiveGoldPricePerGram * conversionFactor, formatter, unitLabel),
                    _buildKaratRow('22K (Jewelry Standard)', provider.goldPriceForCarat(22) * conversionFactor, formatter, unitLabel),
                    _buildKaratRow('21K (Traditional Standard)', provider.goldPriceForCarat(21) * conversionFactor, formatter, unitLabel),
                    _buildKaratRow('18K (Alloy Standard)', provider.goldPriceForCarat(18) * conversionFactor, formatter, unitLabel),
                    _buildKaratRow('Sanatan (Traditional Gold)', provider.goldPriceForCarat(0) * conversionFactor, formatter, unitLabel),
                  ] else ...[
                    _buildKaratRow(
                      AppLocalizations.of(context)!.silver_24k,
                      provider.effectiveSilverPricePerGram * conversionFactor,
                      formatter,
                      unitLabel,
                    ),
                    _buildKaratRow(
                      AppLocalizations.of(context)!.silver_22k,
                      provider.effectiveSilverPricePerGram * 0.925 * conversionFactor,
                      formatter,
                      unitLabel,
                    ),
                    _buildKaratRow(
                      AppLocalizations.of(context)!.silver_21k,
                      provider.effectiveSilverPricePerGram * 0.900 * conversionFactor,
                      formatter,
                      unitLabel,
                    ),
                    _buildKaratRow(
                      AppLocalizations.of(context)!.silver_19k,
                      provider.effectiveSilverPricePerGram * 0.800 * conversionFactor,
                      formatter,
                      unitLabel,
                    ),
                  ],
                ],
              ),
            ),

            // Nisab guidance section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ProfessionalCard(
                padding: const EdgeInsets.all(20),
                borderRadius: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(widget.isGold ? Icons.gavel_rounded : Icons.scale_rounded, color: const Color(0xFFC5A059), size: 28),
                        const SizedBox(width: 12),
                        const Text(
                          'Nisab Threshold Details',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2C3E35)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.isGold
                          ? 'The gold Nisab is defined as 85 grams of pure gold. If your total wealth exceeds the value of 85g gold (${formatter.format(provider.goldNisabThreshold)}), you are eligible to pay Zakat.'
                          : 'The silver Nisab is defined as 595 grams of pure silver (calculated as 612.36g or 595g depending on standard rulings). The app uses the standard silver Nisab threshold of ${formatter.format(provider.silverNisabThreshold)}.',
                      style: const TextStyle(fontSize: 13.5, color: Color(0xFF5F6763), height: 1.45),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildRangeButton(int days) {
    final active = _selectedDaysRange == days;
    return GestureDetector(
      onTap: () => setState(() => _selectedDaysRange = days),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF0E6451) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: active ? Colors.transparent : const Color(0xFFD2DAD6)),
        ),
        child: Text(
          '${days}D',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: active ? Colors.white : const Color(0xFF5F6763),
          ),
        ),
      ),
    );
  }

  Widget _buildKaratRow(String name, double price, NumberFormat formatter, String unitLabel) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ProfessionalCard(
        padding: const EdgeInsets.all(16),
        borderRadius: 16,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF333D39))),
            Text(
              '${formatter.format(price)} / $unitLabel',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0E6451)),
            ),
          ],
        ),
      ),
    );
  }

  String _getDateLabel(int index, int range) {
    final date = DateTime.now().subtract(Duration(days: (range - 1) - index));
    return DateFormat('dd MMM yyyy').format(date);
  }

  void _updateHoverState(Offset localPos, List<double> history) {
    final size = context.size;
    if (size == null) return;
    
    final chartWidth = size.width - 64; // Adjust for card padding
    final stepX = chartWidth / (history.length - 1);
    
    final adjustedX = (localPos.dx - 32).clamp(0.0, chartWidth);
    int index = (adjustedX / stepX).round().clamp(0, history.length - 1);

    final minVal = history.reduce((a, b) => a < b ? a : b);
    final maxVal = history.reduce((a, b) => a > b ? a : b);
    final range = maxVal - minVal == 0 ? 1.0 : maxVal - minVal;
    
    final x = 32 + (index * stepX);
    final y = 180 - 24 - (((history[index] - minVal) / range) * (180 - 48));

    setState(() {
      _hoveredIndex = index;
      _hoverPosition = Offset(x, y);
    });
  }
  Widget _buildUnitTab(String unitCode, String label) {
    final active = _activeUnit == unitCode;
    return GestureDetector(
      onTap: () => setState(() => _activeUnit = unitCode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF0E6451) : const Color(0xFFF0F4F2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: active ? Colors.white : const Color(0xFF5F6763),
          ),
        ),
      ),
    );
  }
}

class InteractiveChartPainter extends CustomPainter {
  final List<double> points;
  final int? hoveredIndex;

  InteractiveChartPainter({required this.points, required this.hoveredIndex});

  @override
  void paint(Canvas canvas, Size size) {
    final minVal = points.reduce((a, b) => a < b ? a : b);
    final maxVal = points.reduce((a, b) => a > b ? a : b);
    final range = maxVal - minVal == 0 ? 1.0 : maxVal - minVal;

    final width = size.width;
    final height = size.height;
    
    final topPad = 24.0;
    final bottomPad = 24.0;
    final drawHeight = height - (topPad + bottomPad);

    final stepX = width / (points.length - 1);

    final List<Offset> coordinates = [];
    for (int i = 0; i < points.length; i++) {
      final x = i * stepX;
      final y = height - bottomPad - (((points[i] - minVal) / range) * drawHeight);
      coordinates.add(Offset(x, y));
    }

    // Draw horizontal grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFFE8ECE9)
      ..strokeWidth = 1.0;
    for (int i = 0; i <= 3; i++) {
      final y = topPad + (drawHeight * (i / 3));
      canvas.drawLine(Offset(0, y), Offset(width, y), gridPaint);
    }

    // Draw gradient area under the curve
    final path = Path();
    path.moveTo(coordinates.first.dx, height - bottomPad);
    for (final pt in coordinates) {
      path.lineTo(pt.dx, pt.dy);
    }
    path.lineTo(coordinates.last.dx, height - bottomPad);
    path.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF0E6451).withOpacity(0.24),
          const Color(0xFF0E6451).withOpacity(0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTRB(0, topPad, width, height - bottomPad));
    canvas.drawPath(path, fillPaint);

    // Draw stroke line
    final linePaint = Paint()
      ..color = const Color(0xFF0E6451)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final strokePath = Path();
    strokePath.moveTo(coordinates.first.dx, coordinates.first.dy);
    for (int i = 1; i < coordinates.length; i++) {
      strokePath.lineTo(coordinates[i].dx, coordinates[i].dy);
    }
    canvas.drawPath(strokePath, linePaint);

    // Draw hovered guideline and dots
    if (hoveredIndex != null && hoveredIndex! < coordinates.length) {
      final pt = coordinates[hoveredIndex!];
      
      // Vertical line
      final vLinePaint = Paint()
        ..color = const Color(0xFF0E6451).withOpacity(0.4)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(pt.dx, topPad), Offset(pt.dx, height - bottomPad), vLinePaint);

      // Pulse dot
      final outerDot = Paint()..color = const Color(0xFF0E6451).withOpacity(0.3);
      final innerDot = Paint()..color = const Color(0xFF0E6451);
      canvas.drawCircle(pt, 8.0, outerDot);
      canvas.drawCircle(pt, 4.0, innerDot);
    }
  }

  @override
  bool shouldRepaint(covariant InteractiveChartPainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.hoveredIndex != hoveredIndex;
  }
}
