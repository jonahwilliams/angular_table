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
    _controller._init();
  }
}
