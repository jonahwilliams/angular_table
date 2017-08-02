part of angular_table.table;

abstract class TableController<T> {
  /// Read-only access to table rows from outside of this library.
  ///
  /// In general you can assume that this is an `EfficientIterable`, and thus
  /// `length` and `elementAt()` are O(1) without calling `toList`.
  Iterable<T> get rows;

  /// Registers [TableDirective] on this controller.
  ///
  /// Internal use only.
  void _register(AngularTableDirective directive);

  /// Triggers a full table rerender.
  ///
  /// Call this method if you are going to change the data in a way that can't
  /// easily be expressed as some combination of the following methods.
  /// This will not trigger changes in rows with the same values.
  void setState(void Function(List<T> data) fn);

  /// Adds a single row of data to the end of the table.
  void add(T data);

  /// Adds multiple rows of data to the end of the table.
  void addAll(Iterable<T> data);

  /// Removes the row at [index] in the table.
  ///
  /// Throws a [StateError] if the index is less than 0 or greater than the
  /// current length of rows.
  void removeAt(int index);

  /// Clears the table of all rows.
  void clear();

  /// Inserts a new row at [index].
  ///
  /// Throws a [StateError] if the index is less than 0 or greater than the
  /// current table length.
  void insert(int index, T data);

  /// Inserts multiple rows at [index].
  ///
  /// Throws a [StateError] if the index is less than 0 or greater than the
  /// current table length.
  void insertAll(int index, Iterable<T> iterable);

  /// Reverses the rows of the table.
  void reverse();

  /// Sorts the rows of the table by [comparator].
  void sort(Comparator<T> comparator);

  /// Call to render the initial table.
  ///
  /// Internal use only.
  void _init();
}
