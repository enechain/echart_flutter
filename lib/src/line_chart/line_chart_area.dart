import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// The plot area of the line chart.
class LineChartArea extends Equatable {
  /// Creates [LineChartArea].
  const LineChartArea({
    this.border = const Border(),
    this.borderRadius = BorderRadius.zero,
    this.padding = EdgeInsets.zero,
    this.color = Colors.transparent,
  });

  /// The border of the plot area.
  final Border border;

  /// The border radius of the plot area.
  final BorderRadius borderRadius;

  /// The padding of the plot area.
  final EdgeInsets padding;

  /// The color of the background.
  final Color color;

  @override
  List<Object?> get props => [
        border,
        borderRadius,
        padding,
        color,
      ];
}
