import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import 'line_chart_label.dart';
import 'line_chart_range.dart';

/// The x-axis for the line chart.
class LineChartXAxis extends Equatable {
  /// Creates [LineChartAxis].
  const LineChartXAxis({
    this.label,
    this.grid,
    this.range,
  });

  /// The label of the x-axis.
  /// When null, the label is not shown.
  final LineChartXLabel? label;

  /// The grid drawn where the label exists.
  /// When null, the grid is not shown.
  final LineChartGrid? grid;

  /// The range of the x-axis.
  /// When null, the range is calculated automatically.
  final LineChartRange? range;

  @override
  List<Object?> get props => [label, grid, range];
}

/// The internal class of the x-axis for the line chart.
@internal
class LineChartXAxisInternal extends Equatable {
  /// Creates [LineChartAxisInternal].
  const LineChartXAxisInternal({
    this.label,
    this.grid,
    required this.range,
  });

  /// The label of the x-axis.
  final LineChartXLabel? label;

  /// The grid drawn where the label exists.
  final LineChartGrid? grid;

  /// The range of the x-axis.
  final LineChartXRangeInternal range;

  @override
  List<Object?> get props => [label, grid, range];
}

/// The y-axis for the line chart.
class LineChartYAxis extends Equatable {
  /// Creates [LineChartYAxis].
  const LineChartYAxis({
    this.label,
    this.grid,
    this.range,
  });

  /// The label of the y-axis.
  /// When null, the label is not shown.
  final LineChartYLabel? label;

  /// The grid drawn where the label exists.
  /// When null, the grid is not shown.
  final LineChartGrid? grid;

  /// The range of the y-axis.
  /// When null, the range is calculated automatically.
  final LineChartRange? range;

  @override
  List<Object?> get props => [label, grid, range];
}

/// The internal class of the y-axis for the line chart.
@internal
class LineChartYAxisInternal extends Equatable {
  /// Creates [LineChartAxisInternal].
  const LineChartYAxisInternal({
    this.label,
    this.grid,
    required this.range,
  });

  /// The label of the y-axis.
  final LineChartYLabel? label;

  /// The grid drawn where the label exists.
  final LineChartGrid? grid;

  /// The range of the y-axis.
  final LineChartYRangeInternal range;

  @override
  List<Object?> get props => [label, grid, range];

  /// Creates a copy of this [LineChartYAxis] but with the given fields replaced with the new values.
  LineChartYAxisInternal copyWith({
    LineChartYLabel? label,
    LineChartGrid? grid,
    LineChartYRangeInternal? range,
  }) {
    return LineChartYAxisInternal(
      label: label ?? this.label,
      grid: grid ?? this.grid,
      range: range ?? this.range,
    );
  }
}

/// The painter determines the appearance of the grid lines.
class LineChartGrid extends Equatable {
  /// Creates [LineChartGrid].
  const LineChartGrid({
    this.color = Colors.grey,
    this.strokeWidth = 1,
  }) : assert(strokeWidth >= 0);

  /// The color of the grid lines.
  final Color color;

  /// The stroke width of the grid lines.
  final double strokeWidth;

  @override
  List<Object?> get props => [color, strokeWidth];
}
