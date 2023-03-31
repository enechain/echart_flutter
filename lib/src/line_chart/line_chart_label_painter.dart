import 'dart:math';

import 'package:flutter/material.dart';

import '../utils/paint.dart';
import 'line_chart_label.dart';
import 'line_chart_range.dart';

/// The painter for the x-label.
class LineChartXLabelPainter extends CustomPainter {
  /// Creates [LineCharXAxisPainter].
  LineChartXLabelPainter({
    required this.label,
    required this.range,
    required this.yAxisWidth,
    required this.padding,
    required this.textScaleFactor,
  });

  /// The label to draw.
  final LineChartXLabel label;

  /// The range the charts draws.
  final LineChartXRangeInternal range;

  /// The width of the y-axis.
  final double yAxisWidth;

  /// The padding of the chart.
  final EdgeInsets? padding;

  /// The text scale factor.
  final double textScaleFactor;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final texts = label.pickTexts(range);

    if (texts.isEmpty) return;
    for (var labelText in texts) {
      final textPainter = createTextPainter(
        text: labelText.text,
        style: label.style,
        textScaleFactor: textScaleFactor,
      );
      final pixelX = getPixelX(rect, range.ratio(labelText.position));
      if (label.hideOverflowedLabels) {
        final width = cos(pi / 180 * label.rotation.abs()) * textPainter.width +
            sin(pi / 180 * label.rotation.abs()) * textPainter.height;

        final minX = pixelX - width / 2;
        final maxX = pixelX + width / 2;
        if (minX < rect.left - yAxisWidth - (padding?.left ?? 0) ||
            maxX > rect.right + (padding?.right ?? 0)) {
          // Don't draw the labelText if it overflows.
          continue;
        }
      }
      canvas
        ..save()
        ..translate(
          pixelX,
          (rect.top + rect.bottom) / 2,
        )
        ..rotate(pi / 180 * label.rotation);
      textPainter.paint(
        canvas,
        Offset(
          -textPainter.width / 2,
          -textPainter.height / 2 + label.spaceFromAxis,
        ),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant LineChartXLabelPainter oldDelegate) {
    return oldDelegate.label != label ||
        oldDelegate.range != range ||
        oldDelegate.yAxisWidth != yAxisWidth ||
        oldDelegate.padding != padding ||
        oldDelegate.textScaleFactor != textScaleFactor;
  }
}

/// The painter for the y-label.
class LineChartYLabelPainter extends CustomPainter {
  /// Creates [LineCharYAxisPainter].
  LineChartYLabelPainter({
    required this.label,
    required this.range,
    required this.textScaleFactor,
  });

  /// The label to draw.
  final LineChartYLabel label;

  /// The range the charts draws.
  final LineChartYRangeInternal range;

  /// The text scale factor.
  final double textScaleFactor;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final texts = label.pickTexts(range);
    if (texts.isEmpty) return;
    for (var labelText in texts) {
      final textPainter = createTextPainter(
        text: labelText.text,
        style: label.style,
        textScaleFactor: textScaleFactor,
      );
      canvas
        ..save()
        ..translate(
          rect.right - textPainter.width,
          getPixelY(rect, range.ratio(labelText.position)) -
              textPainter.height / 2,
        )
        ..rotate(pi / 180 * label.rotation);
      textPainter.paint(
        canvas,
        Offset(-label.spaceFromAxis, 0),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant LineChartYLabelPainter oldDelegate) {
    return oldDelegate.label != label ||
        oldDelegate.range != range ||
        oldDelegate.textScaleFactor != textScaleFactor;
  }
}
