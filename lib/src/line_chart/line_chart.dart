import 'dart:math';

import 'package:flutter/material.dart';

import '../utils/paint.dart';
import 'line_chart_bar_data.dart';
import 'line_chart_data.dart';
import 'line_chart_label.dart';
import 'line_chart_label_painter.dart';
import 'line_chart_painter.dart';
import 'line_chart_selected_spots_painter.dart';
import 'line_chart_spot.dart';
import 'line_chart_tooltip.dart';
import 'line_chart_tooltip_delegate.dart';

/// [LineChart] renders a line chart.
class LineChart extends ImplicitlyAnimatedWidget {
  /// Creates [LineChart].
  const LineChart({
    Key? key,
    required this.data,
    this.tooltip,
    Duration swapAnimationDuration = const Duration(milliseconds: 250),
    Curve swapAnimationCurve = Curves.linear,
  }) : super(
          key: key,
          duration: swapAnimationDuration,
          curve: swapAnimationCurve,
        );

  /// The data determines the appearance of the line chart.
  final LineChartData data;

  /// The tooltip displayed when tapping the line chart.
  /// When null, the tooltip is disabled.
  final LineChartTooltip? tooltip;

  @override
  AnimatedWidgetBaseState<LineChart> createState() => _LineChartState();
}

class _LineChartState extends AnimatedWidgetBaseState<LineChart> {
  NormalizedLineChartDataTween? normalizedLineChartDataTween;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.data.area?.padding ?? EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, constraints) {
          assert(constraints.hasBoundedWidth);
          assert(constraints.hasBoundedHeight);

          return _Chart(
            data: normalizedLineChartDataTween!.evaluate(animation),
            tooltip: widget.tooltip,
            width: constraints.maxWidth,
            height: constraints.maxHeight,
          );
        },
      ),
    );
  }

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    normalizedLineChartDataTween = visitor(
      normalizedLineChartDataTween,
      NormalizedLineChartData.normalized(widget.data),
      (dynamic value) => NormalizedLineChartDataTween(
        begin: value as NormalizedLineChartData,
        end: NormalizedLineChartData.normalized(widget.data),
      ),
    ) as NormalizedLineChartDataTween?;
  }
}

class _Chart extends StatelessWidget {
  const _Chart({
    Key? key,
    required this.data,
    this.tooltip,
    required this.width,
    required this.height,
  }) : super(key: key);
  final NormalizedLineChartData data;
  final LineChartTooltip? tooltip;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final xLabel = data.xAxis.label;
    final yLabel = data.yAxis.label;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final xAxisHeight = data.xAxis.label?.height ??
        _calculateLabelMaxOffset(xLabel, textScaleFactor).dy;
    final yAxisWidth = data.yAxis.label?.width ??
        _calculateLabelMaxOffset(yLabel, textScaleFactor).dx;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (xLabel != null)
          Positioned(
            left: yAxisWidth,
            right: 0,
            height: xAxisHeight,
            bottom: 0,
            child: RepaintBoundary(
              child: CustomPaint(
                painter: LineChartXLabelPainter(
                  label: xLabel,
                  range: data.xAxis.range,
                  yAxisWidth: yAxisWidth,
                  padding: data.area?.padding,
                  textScaleFactor: textScaleFactor,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        if (yLabel != null)
          Positioned(
            left: 0,
            width: yAxisWidth,
            top: 0,
            bottom: xAxisHeight,
            child: RepaintBoundary(
              child: CustomPaint(
                painter: LineChartYLabelPainter(
                  label: yLabel,
                  range: data.yAxis.range,
                  textScaleFactor: textScaleFactor,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        Positioned(
          left: yAxisWidth,
          right: 0,
          top: 0,
          bottom: xAxisHeight,
          child: RepaintBoundary(
            child: CustomPaint(
              painter: LineChartPainter(
                data: data,
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ),
        if (tooltip != null)
          _Tooltip(
            tooltip: tooltip!,
            barsData: data.lineBarsData,
            width: width,
            height: height,
            xAxisHeight: xAxisHeight,
            yAxisWidth: yAxisWidth,
            positionX: data.xAxis.range.position,
            positionY: data.yAxis.range.position,
          )
      ],
    );
  }

  static Offset _calculateLabelMaxOffset(
    LineChartLabel? label,
    double textScaleFactor,
  ) {
    if (label == null || label.texts == null || label.texts!.isEmpty) {
      return Offset.zero;
    }
    final textPainters = label.texts!.map(
      (labelText) => createTextPainter(
        text: labelText.text,
        style: label.style,
        textScaleFactor: textScaleFactor,
      ),
    );
    final maxWidth =
        textPainters.map((textPainter) => textPainter.size.width).reduce(max);
    final maxHeight = textPainters.first.size.height;

    return Offset(
      cos(pi / 180 * label.rotation.abs()) * maxWidth +
          sin(pi / 180 * label.rotation.abs()) * maxHeight +
          label.spaceFromAxis,
      sin(pi / 180 * label.rotation.abs()) * maxWidth +
          cos(pi / 180 * label.rotation.abs()) * maxHeight +
          label.spaceFromAxis,
    );
  }
}

class _Tooltip extends StatefulWidget {
  const _Tooltip({
    Key? key,
    required this.tooltip,
    required this.barsData,
    required this.width,
    required this.height,
    required this.xAxisHeight,
    required this.yAxisWidth,
    required this.positionX,
    required this.positionY,
  }) : super(key: key);

  final LineChartTooltip tooltip;
  final List<LineChartBarData> barsData;
  final double width;
  final double height;
  final double xAxisHeight;
  final double yAxisWidth;
  final double Function(double) positionX;
  final double Function(double) positionY;

  @override
  State<_Tooltip> createState() => _TooltipState();
}

class _TooltipState extends State<_Tooltip> {
  final tapPointNotifier = ValueNotifier<Offset?>(null);
  List<LineChartSpot?> selectedSpots = [];
  List<Color?> selectedSpotsColors = [];

  @override
  void initState() {
    tapPointNotifier.addListener(() {
      if (tapPointNotifier.value == null) {
        if (selectedSpots.isNotEmpty || selectedSpotsColors.isNotEmpty) {
          selectedSpots.clear();
          selectedSpotsColors.clear();
          setState(() {});
        }
      } else {
        final newSpots = _getSelectedSpots(
          widget.width - widget.yAxisWidth,
          tapPointNotifier.value!,
          widget.barsData,
        );
        if (selectedSpots != newSpots) {
          selectedSpots = newSpots;
          selectedSpotsColors = selectedSpots
              .map(
                (spot) => spot == null
                    ? null
                    : widget.barsData
                        .firstWhere(
                          (barData) => barData.spots.contains(spot),
                        )
                        .color,
              )
              .toList();
          setState(() {});
        }
      }
    });
    super.initState();
  }

  static List<LineChartSpot?> _getSelectedSpots(
    double chartWidth,
    Offset offset,
    List<LineChartBarData> barsData,
  ) {
    final selectedSpots = <LineChartSpot?>[];
    final normalizedX = offset.dx / chartWidth;

    var set = <double>{};
    for (final barData in barsData) {
      set = barData.spots.map((e) => e.x).toSet().union(set);
    }
    final candidates = set.toList()
      ..sort(
        (a, b) => (a - normalizedX).abs().compareTo(
              (b - normalizedX).abs(),
            ),
      );
    final mostNearX = candidates.first;

    for (final barData in barsData) {
      final selectedSpot = barData.spots.where((spot) => spot.x == mostNearX);
      if (selectedSpot.isEmpty) {
        selectedSpots.add(null);
      } else {
        selectedSpots.add(selectedSpot.first);
      }
    }

    return selectedSpots;
  }

  @override
  void didUpdateWidget(covariant _Tooltip oldWidget) {
    tapPointNotifier.value = null;
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    tapPointNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: widget.yAxisWidth,
          right: 0,
          top: 0,
          bottom: 0,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanDown: (event) => tapPointNotifier.value = event.localPosition,
            onPanUpdate: (event) =>
                tapPointNotifier.value = event.localPosition,
            onPanEnd: widget.tooltip.dismissCondition ==
                    LineChartTooltipDismissCondition.tapUp
                ? (event) => tapPointNotifier.value = null
                : null,
            onPanCancel: widget.tooltip.dismissCondition ==
                    LineChartTooltipDismissCondition.tapUp
                ? () => tapPointNotifier.value = null
                : null,
            child: const SizedBox.expand(),
          ),
        ),
        if (selectedSpots.isNotEmpty)
          Positioned(
            left: widget.yAxisWidth,
            right: 0,
            top: 0,
            bottom: widget.xAxisHeight,
            child: CustomPaint(
              painter: LineChartSelectedSpotsPainter(
                selectedSpots: selectedSpots,
                colors: selectedSpotsColors,
                style: widget.tooltip.style,
              ),
            ),
          ),
        if (selectedSpots.isNotEmpty)
          Positioned(
            left: widget.yAxisWidth,
            top: 0,
            child: CustomSingleChildLayout(
              delegate: LineChartTooltipDelegate(
                selectedSpots: selectedSpots,
                margin: widget.tooltip.margin,
                chartSize: Size(
                  widget.width - widget.yAxisWidth,
                  widget.height - widget.xAxisHeight,
                ),
              ),
              child: Listener(
                onPointerDown: (_) => widget.tooltip.dismissCondition ==
                        LineChartTooltipDismissCondition.tapTooltip
                    ? tapPointNotifier.value = null
                    : null,
                child: widget.tooltip.builder(
                  selectedSpots
                      .map(
                        (spot) => spot == null
                            ? null
                            : LineChartSpot(
                                widget.positionX(spot.x),
                                widget.positionY(spot.y),
                              ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
