import '../line_chart/line_chart_bar_data.dart';
import '../line_chart/line_chart_spot.dart';
import 'list_wrapper.dart';

Map<ListWrapper<List<Object>>, List<LineChartSpot>> _cachedUnionA = {};
Map<ListWrapper<List<Object>>, List<LineChartSpot>> _cachedUnionB = {};

/// Calculate the y value of the linear interpolation.
double calculateLinearInterpolationY(List<LineChartSpot> spots, double x) {
  var index = 0;
  for (var i = 0; i < spots.length; i++) {
    if (spots[i].x >= x) {
      index = i;
      break;
    }
  }

  if (index == 0) {
    return spots.first.y;
  }

  return ((spots[index].x - x) * spots[index - 1].y +
          (x - spots[index - 1].x) * spots[index].y) /
      (spots[index].x - spots[index - 1].x);
}

/// Generate the union spots of the two lists.
List<LineChartSpot> generateUnionSpots(
  List<LineChartSpot> spots,
  List<double> unionX,
) {
  final newSpots = <LineChartSpot>[];

  for (final x in unionX) {
    final y = calculateLinearInterpolationY(spots, x);
    newSpots.add(LineChartSpot(x, y));
  }

  return newSpots;
}

/// The lerp for use in animation.
List<LineChartSpot>? lerpSpotList(
  List<LineChartSpot>? a,
  List<LineChartSpot>? b,
  double t,
) {
  final aSetX = a!.map((spot) => spot.x).toSet();
  final bSetX = b!.map((spot) => spot.x).toSet();

  final unionX = aSetX.union(bSetX).toList()..sort();

  late List<LineChartSpot> unionA;
  final listWrapperA = [a, unionX].toWrapperClass();
  if (_cachedUnionA.containsKey(listWrapperA)) {
    unionA = _cachedUnionA[listWrapperA]!;
  } else {
    unionA = generateUnionSpots(a, unionX);
    _cachedUnionA[listWrapperA] = unionA;
  }

  late List<LineChartSpot> unionB;
  final listWrapperB = [b, unionX].toWrapperClass();
  if (_cachedUnionB.containsKey(listWrapperB)) {
    unionB = _cachedUnionB[listWrapperB]!;
  } else {
    unionB = generateUnionSpots(b, unionX);
    _cachedUnionB[listWrapperB] = unionB;
  }

  return lerpList(
    unionA,
    unionB,
    t,
    lerp: LineChartSpot.lerp,
  );
}

/// The lerp for use in animation.
List<LineChartBarData>? lerpLineChartBarDataList(
  List<LineChartBarData>? a,
  List<LineChartBarData>? b,
  double t,
) =>
    lerpList(a, b, t, lerp: LineChartBarData.lerp);

/// The lerp for use in animation.
List<T>? lerpList<T>(
  List<T>? a,
  List<T>? b,
  double t, {
  required T Function(T, T, double) lerp,
}) {
  if (a != null && b != null && a.length == b.length) {
    return List.generate(a.length, (i) {
      return lerp(a[i], b[i], t);
    });
  } else if (a != null && b != null) {
    return List.generate(b.length, (i) {
      return lerp(i >= a.length ? b[i] : a[i], b[i], t);
    });
  } else {
    return b;
  }
}

/// The lerp for use in animation.
int lerpInt(int a, int b, double t) {
  return (a + (b - a) * t).round();
}
