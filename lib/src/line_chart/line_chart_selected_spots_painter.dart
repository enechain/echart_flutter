import 'package:flutter/material.dart';

import '../utils/paint.dart';
import 'line_chart_spot.dart';
import 'line_chart_tooltip.dart';

/// [LineChartSelectedSpotsPainter] paints the selected spots on the line chart.
class LineChartSelectedSpotsPainter extends CustomPainter {
  /// Creates [LineChartSelectedSpotsPainter].
  LineChartSelectedSpotsPainter({
    required this.selectedSpots,
    required this.colors,
    required this.style,
  });

  /// The selected spots.
  final List<LineChartSpot?> selectedSpots;

  /// The colors of the selected spots.
  final List<Color?> colors;

  /// The style of the tooltip.
  final LineChartTooltipStyle style;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTRB(0, 0, size.width, size.height);
    final firstSpot = selectedSpots.firstWhere((spot) => spot != null);
    if (firstSpot == null) return;
    final x = getPixelX(rect, firstSpot.x);
    _drawVerticalLine(
      canvas,
      rect,
      x,
      style.verticalLineColor,
      style.verticalLineWidth,
    );
    _drawSelectedSpot(
      canvas,
      rect,
      colors,
      selectedSpots,
      style.selectedSpotSize,
    );
  }

  @override
  bool? hitTest(Offset position) {
    return false;
  }

  static void _drawVerticalLine(
    Canvas canvas,
    Rect rect,
    double x,
    Color color,
    double width,
  ) {
    final paintStroke = Paint()
      ..color = color
      ..strokeWidth = width
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(x, rect.top)
      ..lineTo(x, rect.bottom);
    canvas.drawPath(path, paintStroke);
  }

  static void _drawSelectedSpot(
    Canvas canvas,
    Rect rect,
    List<Color?> colors,
    List<LineChartSpot?> spots,
    double radius,
  ) {
    for (var i = 0; i < spots.length; i++) {
      final spot = spots[i];
      if (spot == null) continue;
      final paintStroke = Paint()
        ..color = colors[i] ?? Colors.transparent
        ..strokeWidth = 1.0
        ..style = PaintingStyle.fill;

      final x = getPixelX(rect, spot.x);
      final y = getPixelY(rect, spot.y);

      final path = Path()
        ..addOval(Rect.fromCircle(center: Offset(x, y), radius: radius));
      canvas.drawPath(path, paintStroke);
    }
  }

  @override
  bool shouldRepaint(covariant LineChartSelectedSpotsPainter oldDelegate) {
    return oldDelegate.selectedSpots != selectedSpots ||
        oldDelegate.colors != colors ||
        oldDelegate.style != style;
  }
}
