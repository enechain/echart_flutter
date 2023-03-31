import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'line_chart_spot.dart';

/// The condition to dismiss the tooltip.
enum LineChartTooltipDismissCondition {
  /// The tooltip will be dismissed when the user tap up.
  tapUp,

  /// The tooltip will be dismissed when the user tap down.
  tapTooltip,
}

/// The style of the tooltip.
class LineChartTooltipStyle extends Equatable {
  /// Creates [LineChartTooltipStyle].
  const LineChartTooltipStyle({
    this.selectedSpotSize = 4,
    this.verticalLineColor = Colors.grey,
    this.verticalLineWidth = 1,
  })  : assert(selectedSpotSize >= 0),
        assert(verticalLineWidth >= 0);

  /// The size of the selected spot.
  final double selectedSpotSize;

  /// The color of the vertical line.
  final Color verticalLineColor;

  /// The width of the vertical line.
  final double verticalLineWidth;

  @override
  List<Object?> get props => [
        selectedSpotSize,
        verticalLineColor,
        verticalLineWidth,
      ];
}

/// The tooltip of the line chart.
class LineChartTooltip extends Equatable {
  /// Creates [LineChartTooltip].
  const LineChartTooltip({
    required this.builder,
    this.dismissCondition = LineChartTooltipDismissCondition.tapUp,
    this.margin = const EdgeInsets.all(8),
    this.style = const LineChartTooltipStyle(),
  });

  /// The builder of the tooltip.
  final Widget Function(List<LineChartSpot?>) builder;

  /// The condition to dismiss the tooltip.
  final LineChartTooltipDismissCondition dismissCondition;

  /// The margin of the tooltip.
  final EdgeInsets margin;

  /// The style of the tooltip.
  final LineChartTooltipStyle style;

  @override
  List<Object?> get props => [
        builder,
        dismissCondition,
        margin,
        style,
      ];
}
