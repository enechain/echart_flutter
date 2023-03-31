import 'package:equatable/equatable.dart';
import 'package:flutter/animation.dart';

import '../utils/lerp.dart';
import 'line_chart_area.dart';
import 'line_chart_axis.dart';
import 'line_chart_bar_data.dart';
import 'line_chart_label.dart';
import 'line_chart_range.dart';
import 'line_chart_spot.dart';

/// The data is required for [LineChart].
class LineChartData extends Equatable {
  /// Creates [LineChartData].
  /// When [xAxis] or [yAxis] is null, the range is calculated automatically and the label is not shown.
  /// When [area] is null, the area is not shown.
  LineChartData({
    required this.lineBarsData,
    LineChartXAxis? xAxis,
    LineChartYAxis? yAxis,
    this.area,
  })  : assert(
          lineBarsData.isNotEmpty ||
              (xAxis?.range?.min != null &&
                  xAxis?.range?.max != null &&
                  yAxis?.range?.min != null &&
                  yAxis?.range?.max != null),
          'If you don\'t have any data, you need to specify the range.',
        ),
        xAxis = LineChartXAxisInternal(
          label: xAxis?.label,
          range: LineChartXRangeInternal.create(
            lineBarsData: lineBarsData,
          ),
          grid: xAxis?.grid,
        ),
        yAxis = LineChartYAxisInternal(
          label: yAxis?.label == null
              ? null
              : LineChartYLabel.create(
                  lineBarsData: lineBarsData,
                  label: yAxis!.label!,
                  range: yAxis.range,
                ),
          range: LineChartYRangeInternal.create(
            lineBarsData: lineBarsData,
            label: yAxis?.label,
            range: yAxis?.range,
          ),
          grid: yAxis?.grid,
        );

  /// The data determines the appearance of the lines.
  final List<LineChartBarData> lineBarsData;

  /// The x-axis drawn on the line chart.
  final LineChartXAxisInternal xAxis;

  /// The y-axis drawn on the line chart.
  final LineChartYAxisInternal yAxis;

  /// The plot area drawn on the line chart.
  final LineChartArea? area;

  @override
  List<Object?> get props => [
        lineBarsData,
        xAxis,
        yAxis,
        area,
      ];
}

/// The normalized data of [LineChartData] for smooth animation.
class NormalizedLineChartData extends Equatable {
  /// Creates [NormalizedLineChartData].
  const NormalizedLineChartData({
    required this.lineBarsData,
    required this.xAxis,
    required this.yAxis,
    this.area,
  });

  ///　The lerp for use in animation.
  factory NormalizedLineChartData.lerp(
    NormalizedLineChartData a,
    NormalizedLineChartData b,
    double t,
  ) {
    return NormalizedLineChartData(
      lineBarsData: lerpLineChartBarDataList(
        a.lineBarsData,
        b.lineBarsData,
        t,
      )!,
      xAxis: b.xAxis,
      yAxis: b.yAxis,
      area: b.area,
    );
  }

  /// Normalizes the data.
  factory NormalizedLineChartData.normalized(LineChartData data) {
    final normalizedLineBarsData = <LineChartBarData>[];
    for (final barData in data.lineBarsData) {
      final spots = barData.spots
          .map(
            (spot) => LineChartSpot(
              data.xAxis.range.ratio(spot.x),
              data.yAxis.range.ratio(spot.y),
            ),
          )
          .toList()
        ..sort(((a, b) => a.x.compareTo(b.x)));

      normalizedLineBarsData.add(
        barData.copyWith(spots: spots),
      );
    }

    return NormalizedLineChartData(
      lineBarsData: normalizedLineBarsData,
      xAxis: data.xAxis,
      yAxis: data.yAxis.copyWith(
        label: data.yAxis.label?.copyWith(
          texts: data.yAxis.label!.texts ??
              data.yAxis.label!.createTexts(data.yAxis.range),
        ),
      ),
      area: data.area,
    );
  }

  /// The data determines the appearance of the lines.
  final List<LineChartBarData> lineBarsData;

  /// The x-axis drawn on the line chart.
  final LineChartXAxisInternal xAxis;

  /// The y-axis drawn on the line chart.
  final LineChartYAxisInternal yAxis;

  /// The plot area drawn on the line chart.
  final LineChartArea? area;

  @override
  List<Object?> get props => [
        lineBarsData,
        xAxis,
        yAxis,
        area,
      ];
}

/// The tween for use in animation.
class NormalizedLineChartDataTween extends Tween<NormalizedLineChartData> {
  /// Creates [NormalizedLineChartDataTween].
  NormalizedLineChartDataTween({
    required NormalizedLineChartData begin,
    required NormalizedLineChartData end,
  }) : super(begin: begin, end: end);

  @override
  NormalizedLineChartData lerp(double t) =>
      NormalizedLineChartData.lerp(begin!, end!, t);
}
