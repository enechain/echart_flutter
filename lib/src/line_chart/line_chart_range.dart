import 'dart:math' as math;

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import 'line_chart_bar_data.dart';
import 'line_chart_label.dart';

/// The range of the line chart.
class LineChartRange extends Equatable {
  /// Creates [LineChartRange].
  /// If you specify both [min] and [max], the range is fixed.
  /// If you specify only one of them, the other is automatically calculated.
  /// If you don't specify any of them, the range is calculated automatically.
  const LineChartRange({this.min, this.max})
      : assert(min == null || max == null || min < max);

  /// The minimum value of the range.
  final double? min;

  /// The maximum value of the range.
  final double? max;

  @override
  List<Object?> get props => [min, max];
}

/// The internal class of the range of the line chart.
@internal
abstract class LineChartRangeInternal extends Equatable {
  /// Creates [LineChartRangeInternal].
  const LineChartRangeInternal({required this.min, required this.max})
      : assert(min < max);

  /// The minimum value of the range.
  final double min;

  /// The maximum value of the range.
  final double max;

  /// The difference between the [min] and the [max].
  double get diff => max - min;

  /// The ratio of the given [position].
  double ratio(double position) => (position - min) / diff;

  /// The position of the given [ratio].
  double position(double ratio) => ratio * diff + min;

  @override
  List<Object?> get props => [min, max];
}

/// The internal class of the range of the x-axis.
@internal
class LineChartXRangeInternal extends LineChartRangeInternal {
  /// Creates [LineChartXRangeInternal].
  const LineChartXRangeInternal({required super.min, required super.max});

  /// Creates [LineChartXRange] from the given [lineBarsData].
  factory LineChartXRangeInternal.create({
    required List<LineChartBarData> lineBarsData,
    LineChartRange? range,
  }) {
    final candidateMin = range?.min ??
        lineBarsData
            .map(
              (barData) => barData.spots.map((spot) => spot.x).reduce(math.min),
            )
            .reduce(math.min);
    final candidateMax = range?.max ??
        lineBarsData
            .map(
              (barData) => barData.spots.map((spot) => spot.x).reduce(math.max),
            )
            .reduce(math.max);

    final min = range?.min ??
        (candidateMin == candidateMax ? candidateMin - 0.01 : candidateMin);
    final max = range?.max ??
        (candidateMin == candidateMax ? candidateMax + 0.01 : candidateMax);

    return LineChartXRangeInternal(min: min, max: max);
  }
}

/// The internal class of the range of the y-axis.
@internal
class LineChartYRangeInternal extends LineChartRangeInternal {
  /// Creates [LineChartYRangeInternal].
  const LineChartYRangeInternal({required super.min, required super.max});

  /// Creates [LineChartYRange] from the given [lineBarsData].
  factory LineChartYRangeInternal.create({
    required List<LineChartBarData> lineBarsData,
    LineChartYLabel? label,
    LineChartRange? range,
  }) {
    final candidateMin = range?.min ??
        lineBarsData
            .map(
              (barData) => barData.spots.map((spot) => spot.y).reduce(math.min),
            )
            .reduce(math.min);
    final candidateMax = range?.max ??
        lineBarsData
            .map(
              (barData) => barData.spots.map((spot) => spot.y).reduce(math.max),
            )
            .reduce(math.max);

    final horizontalInterval = label?.interval ??
        LineChartYLabel.calculateVerticalInterval(
          candidateMin == candidateMax
              ? (candidateMin * 2).abs()
              : candidateMax - candidateMin,
        );

    final min = range?.min ??
        (label == null
            ? candidateMin == candidateMax
                ? candidateMin - 0.05
                : candidateMin - (candidateMax - candidateMin) * 0.05
            : candidateMin == candidateMax
                ? candidateMin > 0
                    ? 0.0
                    : (candidateMin * 2 / horizontalInterval).round() *
                        horizontalInterval
                : (candidateMin / horizontalInterval).floor() *
                    horizontalInterval);

    final max = range?.max ??
        (label == null
            ? candidateMin == candidateMax
                ? candidateMax + 0.05
                : candidateMax + (candidateMax - candidateMin) * 0.05
            : candidateMin == candidateMax
                ? candidateMax > 0
                    ? (candidateMax * 2 / horizontalInterval).round() *
                        horizontalInterval
                    : 0.0
                : (candidateMax / horizontalInterval).ceil() *
                    horizontalInterval);

    return LineChartYRangeInternal(min: min, max: max);
  }
}
