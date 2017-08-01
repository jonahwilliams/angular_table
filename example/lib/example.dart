import 'dart:async';

/// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:math' as math;
import 'package:angular/angular.dart';
import 'package:angular_table/angular_table.dart';
import 'package:angular_components/angular_components.dart';

@Component(
  selector: 'my-app',
  template: r'''
  <div class="table">
    <div class="title">Things to do</div>
    <div class="row-header">
      <div class="header-cell" [style.width.px]="90"></div>
      <div class="header-cell" [style.width.px]="250">Name</div>
      <div class="header-cell" [style.width.px]="250">Completed?</div>
      <div class="header-cell" [style.width.px]="250">Created At</div>
      <div class="header-cell" [style.width.px]="90">Delete</div>
    </div>
    <row *ngTable="let todo of controller; let i = index"  
        [todo]="todo"
        [index]="i"
        (delete)="handleDelete($event)">
    </row>
  </div>
  <material-input [(ngModel)]="todoName" (keyup.enter)="handleAddRow()"></material-input>
  <material-button (trigger)="handleAddRow()" raised>Add Todo</material-button>
  <material-button (trigger)="handleSort()" raised>Sort By Date</material-button>
   <material-button (trigger)="handleShuffle()" raised>Shuffle</material-button>
  <material-button (trigger)="handleAdd5()" raised>Add 5 Todos</material-button>
  ''',
  directives: const [
    AngularTableDirective,
    materialDirectives,
    MaterialIconComponent,
    RowComponent,
  ],
  providers: const [
    materialProviders,
  ],
  preserveWhitespace: false,
)
class AppComponent {
  final _gen = new math.Random();
  final controller = new TableController<Todo>.from([
    new Todo(
        name: 'This is a todo',
        createdAt: new DateTime.fromMicrosecondsSinceEpoch(1000200300000)),
    new Todo(
        name: 'This is another todo',
        createdAt: new DateTime.fromMicrosecondsSinceEpoch(100000100000)),
    new Todo(
        name: 'finish this table',
        createdAt: new DateTime.fromMicrosecondsSinceEpoch(1000002300000)),
    new Todo(
        name: 'eat some food',
        createdAt: new DateTime.fromMicrosecondsSinceEpoch(1000500000000)),
    new Todo(name: 'do some work', createdAt: new DateTime.now()),
  ]);
  final selected = new Set<Todo>();
  String todoName = '';

  /// Deletes the row at [index]
  void handleDelete(int index) {
    controller
      ..removeRow(index)
      ..updateIndex();
  }

  /// Adds a new row to the table.
  void handleAddRow() {
    controller
      ..append(new Todo(name: todoName, createdAt: new DateTime.now()))
      ..updateIndex();
    todoName = '';
  }

  /// Shuffles the rows currently in the table.
  void handleShuffle() {
    controller.setState((rows) {
      rows.shuffle();
    });
  }

  /// Adds 5 todos at once
  void handleAdd5() {
    var newTodos = new List.generate(5, (_) => new Todo.random());
    controller
      ..appendAll(newTodos)
      ..updateIndex();
  }

  void handleSort() {
    controller
      ..sort((left, right) {
        return left.createdAt.compareTo(right.createdAt);
      })
      ..updateIndex();
  }
}

@Component(
  selector: 'row',
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: r'''
  <div class="row" [class.selected]="isSelected">
    <div class="cell" [style.width.px]="90">
        <material-checkbox
            (checkedChange)="isSelected = $event"
            [checked]="isSelected">
        </material-checkbox>
      </div>
      <div class="cell" [style.width.px]="250">{{todo.name}}</div>
      <div class="cell" [style.width.px]="250">{{todo.isDone ? "Complete" : "Incomplete"}}</div>
      <div class="cell" [style.width.px]="250">{{todo.createdAt | date }}</div>
      <div class="cell" [style.width.px]="90">
        <material-button icon (trigger)="handleDelete()">
          <material-icon icon="clear">
          </material-icon>
        </material-button>
      </div>
    </div>
  ''',
  directives: const [
    materialDirectives,
    MaterialIconComponent,
  ],
  pipes: const [
    DatePipe,
  ],
  preserveWhitespace: false,
)
class RowComponent {
  final _deleteController = new StreamController<int>.broadcast();

  @Input()
  Todo todo;

  @Input()
  int index;

  @Output('delete')
  Stream<int> get onItemDeleted => _deleteController.stream;

  RowComponent();

  bool isSelected = false;

  void handleDelete() {
    _deleteController.add(index);
  }
}

class Todo {
  static final _gen = new math.Random();
  static int _nextId = 0;

  final String name;
  final int id;
  bool isDone;
  final DateTime createdAt;

  Todo({this.name, this.createdAt, this.isDone = false}) : id = _nextId++;

  factory Todo.random() {
    var name = new String.fromCharCodes([
      _gen.nextInt(127) + 33,
      _gen.nextInt(127) + 33,
      _gen.nextInt(127) + 33,
      _gen.nextInt(127) + 33,
      _gen.nextInt(127) + 33,
      _gen.nextInt(127) + 33,
    ]);
    return new Todo(
      name: name,
      isDone: false,
      createdAt:
          new DateTime.now().add(new Duration(seconds: _gen.nextInt(2000))),
    );
  }
}
