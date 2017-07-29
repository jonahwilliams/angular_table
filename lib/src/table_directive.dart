// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of angular_table.table;

const _implicit = r'$implicit';

/// Renders table rows from a [TableController].
///
///
/// __example_use__:
///     <row *ngTable="let data of tableController; let i = index">
///       <cell>{{i}}</cell>
///       <cell>{{data.foo}}</cell>
///       <cell>{{data.bar}}</cell>
///     </row>
///
@Directive(selector: '[ngTable][ngTableOf]')
class AngularTableDirective implements OnInit {
  final ViewContainerRef _viewContainer;
  final TemplateRef _templateRef;
  TableController<Object> _controller;

  AngularTableDirective(this._templateRef, this._viewContainer);

  @Input('ngTableOf')
  set controller(TableController<Object> value) {
    if (value == null || identical(value, _controller)) return;
    assert(_controller == null,
        '$this does not support binding multiple controllers');
    _controller = value;
    _controller._register(this);
  }

  @override
  void ngOnInit() {
    _renderAll();
  }

  /// The general purpose update which checks all rows.
  void _renderAll() {
    var currentLength = _viewContainer.length;
    var futureLength = _controller._rows.length;
    for (var i = 0; i < math.min(currentLength, futureLength); i++) {
      _viewContainer.get(i)
        ..setLocal(r'$implicit', _controller._rows[i])
        ..setLocal('index', i);
    }
    // If there are more rows than templates, append more templates.
    if (currentLength < futureLength) {
      for (var i = currentLength; i < futureLength; i++) {
        _viewContainer.insertEmbeddedView(_templateRef, i)
          ..setLocal(_implicit, _controller._rows[i])
          ..setLocal('index', i);
      }
      // Otherwise, remove the extra templates.
    } else {
      for (var i = futureLength; i < currentLength; i++) {
        _viewContainer.remove();
      }
    }
  }

  /// Appends a single row to the table.
  void _didAppend() {
    _viewContainer.insertEmbeddedView(_templateRef, -1)
      ..setLocal(_implicit, _controller._rows.last)
      ..setLocal('index', _controller._rows.length - 1);
  }

  /// Appends multiple rows to the table.
  void _didAppendAll(int oldLength) {
    for (var i = oldLength; i < _controller._rows.length; i++) {
      _viewContainer.insertEmbeddedView(_templateRef, -1)
        ..setLocal(_implicit, _controller._rows[i])
        ..setLocal('index', i);
    }
  }

  /// Prepends a single row to the front of the table.
  ///
  /// Updates all following rows indexes.
  void _didPrepend() {
    _viewContainer.insertEmbeddedView(_templateRef, 0)
      ..setLocal(_implicit, _controller._rows.first)
      ..setLocal('index', 0);
    for (var i = 1; i < _controller._rows.length; i++) {
      _viewContainer.get(i).setLocal('index', i);
    }
  }

  /// Prepends multiple rows to the front of the table.
  ///
  /// Updates all following rows indexes.
  void _didPrependAll(int oldLength) {
    var change = _controller._rows.length - oldLength;
    for (var i = 0; i < change; i++) {
      _viewContainer.insertEmbeddedView(_templateRef, i)
        ..setLocal(_implicit, _controller._rows[i])
        ..setLocal('index', i);
    }
    for (var i = change; i < _controller._rows.length; i++) {
      _viewContainer.get(i).setLocal('index', i);
    }
  }

  /// Removes a row from the table.
  ///
  /// The row will be removed, then all following templates will have their
  /// index local updated.
  void _didRemoveAt(int index) {
    _viewContainer.remove(index);
    for (var i = index; i < _controller._rows.length; i++) {
      _viewContainer.get(i).setLocal('index', i);
    }
  }

  /// Removes all rows from the table.
  void _didClear() {
    _viewContainer.clear();
  }

  /// Inserts a new row at [index].
  void _didInsertAt(int index) {
    _viewContainer.insertEmbeddedView(_templateRef, index)
      ..setLocal(_implicit, _controller._rows[index])
      ..setLocal('index', index);

    for (var i = index + 1; i < _controller._rows.length; i++) {
      _viewContainer.get(i).setLocal('index', i);
    }
  }
}
