// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of angular_table.table;

/// Controlls the rendering of a [TableDirective].
class TableController<T> {
  final List<T> _rows;
  AngularTableDirective _directive;

  /// Creates a new [TableController] populated with [rows].
  ///
  /// This calls `toList` on the iterable to copy it.
  TableController.from(Iterable<T> rows) : _rows = rows.toList();

  /// Creates a new [TableController] with no rows.
  TableController() : _rows = <T>[];

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
    _directive._render();
  }

  /// Appends a single row of data to the end of the table.
  void append(T data) {
    _rows.add(data);
    _directive._viewContainer.insertEmbeddedView(_directive._templateRef, -1)
      ..setLocal(_implicit, _rows.last)
      ..setLocal('index', _rows.length - 1);
  }

  /// Appends multiple rows of data to the end of the table.
  void appendAll(Iterable<T> data) {
    var oldLength = _rows.length;
    _rows.addAll(data);
    for (var i = oldLength; i < _rows.length; i++) {
      _directive._viewContainer.insertEmbeddedView(_directive._templateRef, -1)
        ..setLocal(_implicit, _rows[i])
        ..setLocal('index', i);
    }
  }

  /// Prepends a single row of data at the start of the table.
  void prepend(T data, [bool updateIndex = true]) {
    _rows.insert(0, data);
    _directive._viewContainer.insertEmbeddedView(_directive._templateRef, 0)
      ..setLocal(_implicit, _rows.first)
      ..setLocal('index', 0);
    if (updateIndex) {
      _updateIndex(from: 1);
    }
  }

  /// Prepends multiple rows of data at the start of the table.
  void prependAll(Iterable<T> data, [bool updateIndex = true]) {
    var oldLength = _rows.length;
    _rows.insertAll(0, data);
    var change = _rows.length - oldLength;
    for (var i = 0; i < change; i++) {
      _directive._viewContainer.insertEmbeddedView(_directive._templateRef, i)
        ..setLocal(_implicit, _rows[i])
        ..setLocal('index', i);
    }
    if (updateIndex) {
      _updateIndex(from: change);
    }
  }

  /// Removes the row at [index] in the table.
  ///
  /// Throws a [StateError] if the index is less than 0 or greater than the
  /// current length of rows.
  void removeRow(int index, [bool updateIndex = true]) {
    if (index < 0 || index > _rows.length) {
      throw new StateError('cannot remove $index, not found in range');
    }
    _rows.removeAt(index);
    _directive._viewContainer.remove(index);
    if (updateIndex) {
      _updateIndex(from: index);
    }
  }

  /// Clears the table of all rows.
  void clear() {
    _rows.clear();
    _directive._viewContainer.clear();
  }

  /// Inserts a new row at [index].
  ///
  /// Throws a [StateError] if the index is less than 0 or greater than the
  /// current length of rows.
  void insertRow(int index, T data, [bool updateIndex = true]) {
    if (index < 0 || index > _rows.length) {
      throw new StateError('cannot insert $index, not found in range');
    }
    _rows.insert(index, data);
    _directive._viewContainer.insertEmbeddedView(_directive._templateRef, index)
      ..setLocal(_implicit, _rows[index])
      ..setLocal('index', index);

    if (updateIndex) {
      _updateIndex(from: index + 1);
    }
  }

  /// Reverses the rows of the table.
  void reverse([bool updateIndex = true]) {
    for (var i = 0; i < _rows.length ~/ 2; i++) {
      var temp = _rows[i];
      _rows[i] = _rows[_rows.length - 1 - i];
      _rows[_rows.length - 1 - i] = temp;
    }
    for (var i = 0; i < _directive._viewContainer.length ~/ 2; i++) {
      var view = _directive._viewContainer.detach(i);
      var other = _directive._viewContainer
          .detach(_directive._viewContainer.length - 1 - i);
      _directive._viewContainer.insert(other, i);
      _directive._viewContainer
          .insert(view, _directive._viewContainer.length - i);
    }
    if (updateIndex) {
      _updateIndex(from: 0);
    }
  }

  void _updateIndex({int from = 0}) {
    for (var i = from; i < _directive._viewContainer.length; i++) {
      _directive._viewContainer.get(i)..setLocal('index', i);
    }
  }
}
