import 'package:flutter/material.dart';

import '../utils/dash.dart';
import '../utils/paint.dart';
import 'line_chart_area.dart';
import 'line_chart_axis.dart';
import 'line_chart_bar_data.dart';
import 'line_chart_data.dart';

/// The painter for the line chart.
class LineChartPainter extends CustomPainter {
  /// Creates [LineChartPainter].
  LineChartPainter({
    required this.data,
  });

  /// The normalized data for painting the line chart.
  final NormalizedLineChartData data;

  static final Map<LineChartBarData, List<Offset>> _cachedOffsets = {};

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTRB(0, 0, size.width, size.height);

    final rrect = RRect.fromRectAndCorners(
      rect,
      topLeft:
          data.area == null ? Radius.zero : data.area!.borderRadius.topLeft,
      topRight:
          data.area == null ? Radius.zero : data.area!.borderRadius.topRight,
      bottomLeft:
          data.area == null ? Radius.zero : data.area!.borderRadius.bottomLeft,
      bottomRight:
          data.area == null ? Radius.zero : data.area!.borderRadius.bottomRight,
    );

    canvas.clipRRect(rrect);

    if (data.area != null) {
      _drawArea(canvas, rrect, data.area!);
    }

    if (data.xAxis.label != null &&
        data.xAxis.label!.texts != null &&
        data.xAxis.grid != null) {
      _drawXGrid(canvas, rect, data.xAxis, data.xAxis.range.ratio);
    }

    if (data.yAxis.label != null &&
        data.yAxis.label!.texts != null &&
        data.yAxis.grid != null) {
      _drawYGrid(canvas, rect, data.yAxis, data.yAxis.range.ratio);
    }

    for (final barData in data.lineBarsData) {
      _drawChart(canvas, rect, barData);
    }

    for (final barData in data.lineBarsData) {
      if (barData.point != null) {
        _drawPoint(
          canvas,
          rect,
          barData,
          barData.point?.fillColor ?? data.area?.color,
        );
      }
    }

    if (data.area != null) {
      _drawBorder(canvas, rect, data.area!);
    }
  }

  @override
  bool shouldRepaint(covariant LineChartPainter oldDelegate) {
    return oldDelegate.data != data;
  }

  static void _drawArea(
    Canvas canvas,
    RRect rrect,
    LineChartArea area,
  ) =>
      canvas.drawRRect(rrect, Paint()..color = area.color);

  /// Creates the points for the line chart.
  static List<Offset> createPlotPoints(
    Rect rect,
    LineChartBarData lineBarData,
  ) {
    if (_cachedOffsets.containsKey(lineBarData)) {
      return _cachedOffsets[lineBarData]!;
    }

    final points = <Offset>[];
    for (final spot in lineBarData.spots) {
      final x = getPixelX(rect, spot.x);
      final y = getPixelY(rect, spot.y);
      points.add(Offset(x, y));
    }
    return points;
  }

  static void _drawXGrid(
    Canvas canvas,
    Rect rect,
    LineChartXAxisInternal xAxis,
    double Function(double) ratioX,
  ) {
    for (final labelText in xAxis.label!.texts!) {
      final pixelX = getPixelX(rect, ratioX(labelText.position));
      if (pixelX > rect.left && pixelX < rect.right) {
        canvas.drawLine(
          Offset(pixelX, rect.top),
          Offset(pixelX, rect.bottom),
          Paint()
            ..color = xAxis.grid!.color
            ..strokeWidth = xAxis.grid!.strokeWidth,
        );
      }
    }
  }

  static void _drawYGrid(
    Canvas canvas,
    Rect rect,
    LineChartYAxisInternal yAxis,
    double Function(double) ratioY,
  ) {
    for (final labelText in yAxis.label!.texts!) {
      final pixelY = getPixelY(rect, ratioY(labelText.position));
      if (pixelY > rect.top && pixelY < rect.bottom) {
        canvas.drawLine(
          Offset(rect.left, pixelY),
          Offset(rect.right, pixelY),
          Paint()
            ..color = yAxis.grid!.color
            ..strokeWidth = yAxis.grid!.strokeWidth,
        );
      }
    }
  }

  static void _drawChart(Canvas canvas, Rect rect, LineChartBarData barData) {
    final paintStroke = Paint()
      ..color = barData.color
      ..strokeWidth = barData.strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = barData.strokeCap;

    final points = createPlotPoints(rect, barData);

    if (points.length == 1) {
      canvas.drawCircle(
        points.first,
        barData.strokeWidth * 2,
        paintStroke..style = PaintingStyle.fill,
      );
      return;
    }

    var path = Path()..addPolygon(points, false);

    if (barData.dashArray != null) {
      path = calculateDashPath(
        path,
        dashArray: CircularIntervalList(barData.dashArray!),
      );
    }

    canvas.drawPath(path, paintStroke);
  }

  static void _drawPoint(
    Canvas canvas,
    Rect rect,
    LineChartBarData barData,
    Color? color,
  ) {
    final paintCircle = Paint()
      ..color = color ?? Colors.transparent
      ..style = PaintingStyle.fill
      ..strokeCap = barData.strokeCap;
    final paintBorder = Paint()
      ..color = barData.color
      ..strokeWidth = barData.point!.strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = barData.strokeCap;

    final points = createPlotPoints(rect, barData);
    for (final point in points) {
      canvas.drawCircle(point, barData.point!.size, paintCircle);
      canvas.drawCircle(point, barData.point!.size, paintBorder);
    }
  }

  static void _drawBorder(Canvas canvas, Rect rect, LineChartArea area) {
    area.border.paint(
      canvas,
      rect,
      borderRadius: area.borderRadius,
    );
  }
}
