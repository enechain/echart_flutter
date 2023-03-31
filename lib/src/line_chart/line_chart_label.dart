import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'line_chart_bar_data.dart';
import 'line_chart_range.dart';

/// The label of the line chart.
abstract class LineChartLabel extends Equatable {
  /// Creates [LineChartLabel].
  const LineChartLabel({
    this.texts,
    this.rotation = 0,
    this.style,
    this.spaceFromAxis = 4,
  });

  /// The list of the label text.
  final List<LineChartLabelText>? texts;

  /// The rotation angle of the label. The unit is degree.
  final double rotation;

  /// The style of the label.
  final TextStyle? style;

  /// The space from the axis.
  final double spaceFromAxis;

  /// Picks the label texts to show.
  List<LineChartLabelText> pickTexts(LineChartRangeInternal range);

  @override
  List<Object?> get props => [
        texts,
        rotation,
        style,
        spaceFromAxis,
      ];
}

/// The alignment of the x-axis labels.
enum LineChartXLabelAlignment {
  /// Place the free space evenly between the children.
  spaceBetween,

  /// Place the free space evenly between the children as well as half of that
  /// space before and after the first and last child.
  spaceAround,

  /// Place the free space evenly between the children as well as before and
  /// after the first and last child.
  spaceEvenly,
}

/// The x-label of the line chart.
class LineChartXLabel extends LineChartLabel {
  /// Creates [LineChartXLabel].
  const LineChartXLabel({
    super.texts,
    super.rotation,
    super.style,
    super.spaceFromAxis,
    this.alignment = LineChartXLabelAlignment.spaceBetween,
    this.count,
    this.hideOverflowedLabels = true,
    this.height,
  })  : assert(
          count == null || count > 0,
          'count must be greater than 0.',
        ),
        assert(
          height == null || height > 0,
          'height must be greater than 0.',
        );

  /// The alignment of the x-axis labels.
  final LineChartXLabelAlignment alignment;

  /// The number of labels to show.
  /// If this is null, all labels will be shown.
  final int? count;

  /// The height of the label.
  /// If this is null, the height will be calculated automatically.
  final double? height;

  /// Whether to hide the labels that overflow the chart.
  /// If this is true, the labels that overflow the chart will be hidden.
  final bool hideOverflowedLabels;

  @override
  List<Object?> get props =>
      [super.props, alignment, count, height, hideOverflowedLabels];

  @override
  List<LineChartLabelText> pickTexts(LineChartRangeInternal range) {
    if (texts == null || texts!.isEmpty) return [];

    final textsInRange = texts!
        .where(
          (text) => text.position >= range.min && text.position <= range.max,
        )
        .toList();

    if (count == null) {
      return textsInRange;
    }

    final shownLabels = <LineChartLabelText>[];
    switch (alignment) {
      case LineChartXLabelAlignment.spaceBetween:
        final dx = range.diff / (count! - 1);
        for (var i = 0; i < count!; i++) {
          final x = range.min + dx * i;
          final text = texts!.reduce(
            (a, b) => (a.position - x).abs() < (b.position - x).abs() ? a : b,
          );
          if (!shownLabels.contains(text)) shownLabels.add(text);
        }
        return shownLabels;
      case LineChartXLabelAlignment.spaceAround:
        final dx = range.diff / count! / 2;
        for (var i = 0; i < count!; i++) {
          final x = range.min + dx * (2 * i + 1);
          final text = texts!.reduce(
            (a, b) => (a.position - x).abs() < (b.position - x).abs() ? a : b,
          );
          if (!shownLabels.contains(text)) shownLabels.add(text);
        }
        return shownLabels;
      case LineChartXLabelAlignment.spaceEvenly:
        final dx = range.diff / (count! + 1);
        for (var i = 0; i < count!; i++) {
          final x = range.min + dx * (i + 1);
          final text = texts!.reduce(
            (a, b) => (a.position - x).abs() < (b.position - x).abs() ? a : b,
          );
          if (!shownLabels.contains(text)) shownLabels.add(text);
        }
        return shownLabels;
    }
  }
}

/// The y-label of the line chart.
class LineChartYLabel extends LineChartLabel {
  /// Creates [LineChartYLabel].
  const LineChartYLabel({
    super.texts,
    super.rotation,
    super.style,
    super.spaceFromAxis,
    this.interval,
    this.width,
  })  : assert(
          interval == null || interval > 0,
          'interval must be greater than 0.',
        ),
        assert(
          width == null || width > 0,
          'width must be greater than 0.',
        );

  /// The interval of the labels.
  /// If this is null, the interval will be calculated automatically.
  final double? interval;

  /// The width of the label.
  /// If this is null, the width will be calculated automatically.
  final double? width;

  /// Creates [LineChartYLabel] from the given [lineBarsData].
  factory LineChartYLabel.create({
    required List<LineChartBarData> lineBarsData,
    required LineChartYLabel label,
    LineChartRange? range,
  }) {
    final candidateMin = range?.min ??
        lineBarsData
            .map((barData) => barData.spots.map((spot) => spot.y).reduce(min))
            .reduce(min);
    final candidateMax = range?.max ??
        lineBarsData
            .map((barData) => barData.spots.map((spot) => spot.y).reduce(max))
            .reduce(max);

    return LineChartYLabel(
      texts: label.texts,
      rotation: label.rotation,
      style: label.style,
      spaceFromAxis: label.spaceFromAxis,
      interval: label.interval ??
          calculateVerticalInterval(
            candidateMin == candidateMax
                ? (candidateMin * 2).abs()
                : candidateMax - candidateMin,
          ),
      width: label.width,
    );
  }

  /// Calculates the vertical interval.
  static double calculateVerticalInterval(double diff) {
    var verticalInterval =
        pow(10, diff.floor().toString().length - 1).toDouble();
    final quotient = diff / verticalInterval;
    if (quotient >= 5) {
      return 5.0 * verticalInterval;
    }

    if (quotient <= 2) {
      return verticalInterval / 2.0;
    }

    return verticalInterval;
  }

  @override
  List<LineChartLabelText> pickTexts(LineChartRangeInternal range) {
    if (texts == null || texts!.isEmpty) return [];

    final textsInRange = texts!
        .where(
          (text) => text.position >= range.min && text.position <= range.max,
        )
        .toList();

    return textsInRange;
  }

  /// Creates a copy of this [LineChartYLabel] but with the given fields
  LineChartYLabel copyWith({
    List<LineChartLabelText>? texts,
    double? rotation,
    TextStyle? style,
    double? spaceFromAxis,
    double? interval,
    double? width,
  }) {
    return LineChartYLabel(
      texts: texts ?? this.texts,
      rotation: rotation ?? this.rotation,
      style: style ?? this.style,
      spaceFromAxis: spaceFromAxis ?? this.spaceFromAxis,
      interval: interval ?? this.interval,
      width: width ?? this.width,
    );
  }

  /// Creates the label texts.
  List<LineChartLabelText> createTexts(LineChartYRangeInternal range) {
    final texts = <LineChartLabelText>[];
    for (var position = range.min;
        position <= range.max;
        position += interval!) {
      final text =
          interval! >= 1 ? position.toInt().toString() : position.toString();
      texts.add(LineChartLabelText(position, text));
    }
    return texts;
  }
}

/// The label text of the line chart.
class LineChartLabelText extends Equatable {
  /// Creates [LineChartLabelText].
  const LineChartLabelText(
    this.position,
    this.text,
  );

  /// The position of the label.
  final double position;

  /// The text of the label.
  final String text;

  @override
  List<Object?> get props => [position, text];
}
