import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'line_chart_spot.dart';

/// The delegate of the tooltip.
class LineChartTooltipDelegate extends SingleChildLayoutDelegate {
  /// Creates [LineChartTooltipDelegate].
  LineChartTooltipDelegate({
    required this.selectedSpots,
    required this.margin,
    required this.chartSize,
  });

  /// The selected spots.
  final List<LineChartSpot?> selectedSpots;

  /// The margin of the tooltip.
  final EdgeInsets margin;

  /// The size of the chart.
  final Size chartSize;

  @override
  Size getSize(BoxConstraints constraints) {
    return chartSize;
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final firstSpot = selectedSpots.firstWhere((spot) => spot != null);
    if (firstSpot == null) return Offset.zero;
    final x = firstSpot.x * chartSize.width;

    double left = x + margin.left;
    final maxLeft = chartSize.width - childSize.width - margin.horizontal;
    final reversedLeft = x - childSize.width - margin.right;
    if (left > maxLeft && reversedLeft > 0) {
      left = reversedLeft;
    }

    final y = (1 -
            selectedSpots.fold(0.0, (sum, spot) {
                  if (spot == null) return sum;
                  return spot.y + sum;
                }) /
                selectedSpots.where((spot) => spot != null).length) *
        chartSize.height;

    double top = y - childSize.height / 2;
    final minTop = margin.top;
    final maxTop = chartSize.height - childSize.height - margin.bottom;
    if (minTop > maxTop) {
      top = minTop;
    } else {
      top = clampDouble(top, minTop, maxTop);
    }
    return Offset(left, top);
  }

  @override
  bool shouldRelayout(covariant LineChartTooltipDelegate oldDelegate) {
    return oldDelegate.selectedSpots != selectedSpots ||
        oldDelegate.margin != margin ||
        oldDelegate.chartSize != chartSize;
  }
}
