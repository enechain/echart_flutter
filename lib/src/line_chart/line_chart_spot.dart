import 'dart:ui';

import 'package:equatable/equatable.dart';

/// The spot of the line chart.
class LineChartSpot extends Equatable {
  /// Creates [LineChartSpot].
  const LineChartSpot(this.x, this.y);

  /// The lerp for use in animation.
  factory LineChartSpot.lerp(LineChartSpot a, LineChartSpot b, double t) =>
      LineChartSpot(
        lerpDouble(a.x, b.x, t)!,
        lerpDouble(a.y, b.y, t)!,
      );

  /// The x value of the spot.
  final double x;

  /// The y value of the spot.
  final double y;

  @override
  List<Object?> get props => [x, y];
}
