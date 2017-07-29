// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of angular_table.table;

/// Controlls the rendering of a [TableDirective].
class TableController<T> {
  final List<T> _rows;
  AngularTableDirective _directive;

  /// Creates a new [TableController] with no rows.
  TableController.empty() : _rows = <T>[];

  /// Creates a new [TableController] populated with [rows].
  ///
  /// This calls `toList` on the iterable to copy it.
  TableController.from(Iterable<T> rows) : _rows = rows.toList();

  /// Read-only access to table rows from outside of this library.
  ///
  /// In general you can assume that this is an `EfficientIterable`, and thus
  /// `length` and `elementAt()` are O(1) without calling `toList`.
  Iterable<T> get rows => _rows;

  /// Registers [TableDirective] on this controller.
  ///
  /// Internal use only.
  void _register(AngularTableDirective directive) {
    _directive = directive;
  }

  /// Triggers a table rerender.
  ///
  /// Call this method if you are going to change the data in a way that can't
  /// easily be expressed as some combination of the following methods.
  /// This will not trigger changes in rows with the same values.
  void setState(void Function(List<T> data) fn) {
    fn(_rows);
    _directive._renderAll();
  }

  /// Appends a single row of data to the end of the table.
  void append(T data) {
    _rows.add(data);
    _directive._didAppend();
  }

  /// Appends multiple rows of data to the end of the table.
  void appendAll(Iterable<T> data) {
    var oldLength = _rows.length;
    _rows.addAll(data);
    _directive._didAppendAll(oldLength);
  }

  /// Prepends a single row of data at the start of the table.
  void prepend(T data) {
    _rows.insert(0, data);
    _directive._didPrepend();
  }

  /// Prepends multiple rows of data at the start of the table.
  void prependAll(Iterable<T> data) {
    var oldLength = _rows.length;
    _rows.insertAll(0, data);
    _directive._didPrependAll(oldLength);
  }

  /// Removes the row at [index] in the table.
  ///
  /// Throws a [StateError] if the index is less than 0 or greater than the
  /// current length of rows.
  void removeRow(int index) {
    if (index < 0 || index > _rows.length) {
      throw new StateError('cannot remove $index, not found in range');
    }
    _rows.removeAt(index);
    _directive._didRemoveAt(index);
  }

  /// Clears the table of all rows.
  void clear() {
    _rows.clear();
    _directive._didClear();
  }

  /// Inserts a new row at [index].
  ///
  /// Throws a [StateError] if the index is less than 0 or greater than the
  /// current length of rows.
  void insertRow(int index, T data) {
    if (index < 0 || index > _rows.length) {
      throw new StateError('cannot insert $index, not found in range');
    }
    _rows.insert(index, data);
    _directive._didInsertAt(index);
  }
}
