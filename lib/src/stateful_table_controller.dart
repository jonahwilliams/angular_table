// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of angular_table.table;

/// A [TableController] which preserves component state.
class StatefulTableController<T> implements TableController<T> {
  final List<T> _rows;
  final _viewIndex = new HashMap<ViewRef, T>.identity();
  final HashMap<T, ViewRef> _rowIndex;
  AngularTableDirective _directive;

  /// Creates a new [TableController] populated with [rows].
  ///
  /// This calls `toList` on the iterable to copy it.
  factory StatefulTableController(
      {Iterable<T> rows = const [], Equality<T> equality = identical}) {
    var rowCopy = rows.toList();
    var rowIndex = new HashMap<T, ViewRef>(equals: equality);
    return new StatefulTableController._(rowCopy, rowIndex);
  }

  StatefulTableController._(this._rows, this._rowIndex);

  @override
  Iterable<T> get rows => _rows;

  @override
  void _register(AngularTableDirective directive) {
    _directive = directive;
  }

  @override
  void setState(void Function(List<T> data) fn) {
    _rowIndex.clear();
    var oldLength = _directive._viewContainer.length ?? 0;
    for (var i = _rows.length - 1; i > -1; i--) {
      _rowIndex[_rows[i]] = _directive._viewContainer.detach();
    }
    fn(_rows);
    if (_rows.length == 0) {
      _directive._viewContainer.clear();
    } else if (oldLength == 0 && _rows.length > 0) {
      for (var i = 0; i < _rows.length; i++) {
        _directive._viewContainer
            .insertEmbeddedView(_directive._templateRef, -1)
              ..setLocal(_implicit, _rows[i])
              ..setLocal('index', i);
      }
    } else {
      for (var i = 0; i < _rows.length; i++) {
        var view = _rowIndex[_rows[i]];
        if (view != null) {
          _directive._viewContainer
            ..insert(view)
            ..get(i).setLocal('index', i);
        } else {
          _directive._viewContainer
              .insertEmbeddedView(_directive._templateRef, i)
                ..setLocal(_implicit, _rows[i])
                ..setLocal('index', i);
        }
      }
    }
  }

  @override
  void add(T data) {
    _rows.add(data);
    _directive._viewContainer.insertEmbeddedView(_directive._templateRef, -1)
      ..setLocal(_implicit, _rows.last)
      ..setLocal('index', _rows.length - 1);
  }

  @override
  void addAll(Iterable<T> data) {
    var oldLength = _rows.length;
    _rows.addAll(data);
    for (var i = oldLength; i < _rows.length; i++) {
      _directive._viewContainer.insertEmbeddedView(_directive._templateRef, -1)
        ..setLocal(_implicit, _rows[i])
        ..setLocal('index', i);
    }
  }

  @override
  void removeAt(int index, [bool updateIndex = true]) {
    if (index < 0 || index > _rows.length) {
      throw new StateError('cannot remove $index, not found in range');
    }
    _rows.removeAt(index);
    _directive._viewContainer.remove(index);
    if (updateIndex) {
      for (var i = index; i < _directive._viewContainer.length; i++) {
        _directive._viewContainer.get(i)..setLocal('index', i);
      }
    }
  }

  @override
  void clear() {
    _rows.clear();
    _viewIndex.clear();
    _directive._viewContainer.clear();
  }

  @override
  void insert(int index, T data, [bool updateIndex = true]) {
    if (index < 0 || index > _rows.length) {
      throw new StateError('cannot insert $index, not found in range');
    }
    _rows.insert(index, data);
    _directive._viewContainer.insertEmbeddedView(_directive._templateRef, index)
      ..setLocal(_implicit, _rows[index])
      ..setLocal('index', index);
    for (var i = 0; i < _directive._viewContainer.length; i++) {
      _directive._viewContainer.get(i)..setLocal('index', i);
    }
    if (updateIndex) {
      for (var i = index + 1; i < _directive._viewContainer.length; i++) {
        _directive._viewContainer.get(i)..setLocal('index', i);
      }
    }
  }

  @override
  void insertAll(int index, Iterable<T> iterable, [bool updateIndex = true]) {
    if (index < 0 || index > _rows.length) {
      throw new StateError('cannot insert $index, not found in range');
    }
    var oldSize = _rows.length;
    _rows.insertAll(index, iterable);
    var change = _rows.length - oldSize;

    for (var i = 0; i < change; i++) {
      _directive._viewContainer
          .insertEmbeddedView(_directive._templateRef, index + i)
            ..setLocal(_implicit, _rows[index])
            ..setLocal('index', index);
    }

    if (updateIndex) {
      for (var i = index + change; i < _directive._viewContainer.length; i++) {
        _directive._viewContainer.get(i)..setLocal('index', i);
      }
    }
  }

  @override
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
      for (var i = 0; i < _directive._viewContainer.length; i++) {
        _directive._viewContainer.get(i)..setLocal('index', i);
      }
    }
  }

  @override
  void sort(Comparator<T> comparator, [bool updateIndex = true]) {
    var views = <ViewRef>[]..length = _rows.length;
    for (var i = views.length - 1; i > -1; i--) {
      var view = _directive._viewContainer.detach();
      _viewIndex[view] = _rows[i];
      views[i] = view;
    }
    views.sort((left, right) {
      return comparator(_viewIndex[left], _viewIndex[right]);
    });
    _rows.sort(comparator);
    print(_rows);
    for (var i = 0; i < _rows.length; i++) {
      _directive._viewContainer.insert(views[i]);
    }
    if (updateIndex) {
      for (var i = 0; i < _directive._viewContainer.length; i++) {
        _directive._viewContainer.get(i)..setLocal('index', i);
      }
    }
  }

  @override
  void _init() {
    for (var i = 0; i < _rows.length; i++) {
      _directive._viewContainer.insertEmbeddedView(_directive._templateRef, i)
        ..setLocal(_implicit, _rows[i])
        ..setLocal('index', i);
    }
  }
}
