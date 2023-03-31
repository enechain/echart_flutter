import 'dart:ui';

/// A list that returns the values in a circular manner.
class CircularIntervalList<T> {
  /// Creates [CircularIntervalList].
  CircularIntervalList(this._values);

  final List<T> _values;
  int _index = 0;

  /// Returns the next value in a circular manner.
  T get next {
    if (_index >= _values.length) {
      _index = 0;
    }
    return _values[_index++];
  }
}

/// Returns a path with dashes.
Path calculateDashPath(
  Path path, {
  required CircularIntervalList<double> dashArray,
}) {
  assert(dashArray._values.every((value) => value > 0));
  final dashPath = Path();
  for (final metric in path.computeMetrics()) {
    var distance = 0.0;
    var draw = true;
    while (distance < metric.length) {
      final length = dashArray.next;
      if (draw) {
        dashPath.addPath(
          metric.extractPath(distance, distance + length),
          Offset.zero,
        );
      }
      distance += length;
      draw = !draw;
    }
  }

  return dashPath;
}
