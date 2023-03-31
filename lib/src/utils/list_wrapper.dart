import 'package:equatable/equatable.dart';

/// A wrapper class for List<T> to make it Equatable.
class ListWrapper<T> extends Equatable {
  /// Creates [ListWrapper].
  const ListWrapper(this.list);

  /// The list.
  final List<T> list;

  @override
  List<Object?> get props => [list];
}

/// An extension for List<T> to make it Equatable.
extension ListExtension<T> on List<T> {
  /// Wraps the list to make it Equatable.
  ListWrapper<T> toWrapperClass() => ListWrapper<T>(this);
}
