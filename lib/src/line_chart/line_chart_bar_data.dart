import 'dart:ui';

import 'package:equatable/equatable.dart';

import '../utils/lerp.dart';
import 'line_chart_spot.dart';

/// The bar data determines the appearances of the line.
class LineChartBarData extends Equatable {
  /// Creates [LineChartBarData].
  const LineChartBarData({
    required this.spots,
    required this.color,
    this.strokeWidth = 2,
    this.strokeCap = StrokeCap.round,
    this.point,
    this.dashArray,
  }) : assert(strokeWidth >= 0);

  /// The series of the spot.
  final List<LineChartSpot> spots;

  /// The color of this line.
  final Color color;

  /// The stroke width of this line.
  final double strokeWidth;

  /// The stroke cap of this line.
  final StrokeCap strokeCap;

  /// The data point of this line.
  /// If null, the data point will not be drawn.
  final LineChartPoint? point;

  /// The dash array of this line. Used to represent dotted and dashed lines.
  /// [DashArray] provides some common dash arrays.
  final List<double>? dashArray;

  ///　The lerp for use in animation.
  factory LineChartBarData.lerp(
    LineChartBarData a,
    LineChartBarData b,
    double t,
  ) =>
      LineChartBarData(
        spots: lerpSpotList(a.spots, b.spots, t)!,
        color: Color.lerp(a.color, b.color, t)!,
        strokeWidth: lerpDouble(a.strokeWidth, b.strokeWidth, t)!,
        strokeCap: b.strokeCap,
        point: b.point,
        dashArray: b.dashArray,
      );

  /// Creates a copy of this [LineChartBarData] but with the given fields replaced with the new values.
  LineChartBarData copyWith({
    List<LineChartSpot>? spots,
    Color? color,
    double? strokeWidth,
    StrokeCap? strokeCap,
    LineChartPoint? point,
    List<double>? dashArray,
  }) {
    return LineChartBarData(
      spots: spots ?? this.spots,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      strokeCap: strokeCap ?? this.strokeCap,
      point: point ?? this.point,
      dashArray: dashArray ?? this.dashArray,
    );
  }

  @override
  List<Object?> get props => [
        spots,
        color,
        strokeWidth,
        strokeCap,
        point,
        dashArray,
      ];
}

/// The dash array of the line.
abstract class DashArray {
  /// The dotted line.
  static List<double> dotted([double strokeWidth = 2.0]) =>
      [0.0, 2.0 * strokeWidth];

  /// The dashed line.
  static List<double> dashed([double strokeWidth = 2.0]) =>
      [3.0 * strokeWidth, 2.0 * strokeWidth];
}

/// The data point type.
enum LineChartPointType {
  /// The circle type
  circle
}

/// The data point for determining the appearance of data points.
class LineChartPoint extends Equatable {
  /// Creates [LineChartPoint].
  const LineChartPoint({
    required this.type,
    this.fillColor,
    this.size = 4,
    this.strokeWidth = 2,
  })  : assert(size >= 0),
        assert(strokeWidth >= 0);

  /// The type of the point.
  final LineChartPointType type;

  /// The fill color of the point.
  /// If null, the color of the area color will be used.
  final Color? fillColor;

  /// The size of the point.
  final double size;

  /// The stroke width of the point.
  final double strokeWidth;

  @override
  List<Object?> get props => [type, fillColor, size, strokeWidth];
}
