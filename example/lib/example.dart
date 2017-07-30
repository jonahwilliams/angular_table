/// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:math' as math;
import 'package:angular/angular.dart';
import 'package:angular_table/angular_table.dart';
import 'package:angular_components/angular_components.dart';

@Component(
  selector: 'my-app',
  templateUrl: 'example.html',
  directives: const [
    AngularTableDirective,
    materialDirectives,
    MaterialIconComponent,
  ],
  providers: const [
    materialProviders,
  ],
  pipes: const [
    DatePipe,
  ],
  preserveWhitespace: false,
)
class AppComponent {
  final controller = new TableController<Todo>.from([
    new Todo(name: 'This is a todo', createdAt: new DateTime.now()),
    new Todo(name: 'This is another todo', createdAt: new DateTime.now()),
    new Todo(name: 'finish this table', createdAt: new DateTime.now()),
    new Todo(name: 'eat some food', createdAt: new DateTime.now()),
    new Todo(name: 'do some work', createdAt: new DateTime.now()),
  ]);
  final selected = new Set<Todo>();
  String todoName = '';

  /// Deletes the row at [index]
  void handleDeleteRow(int index) {
    controller.removeRow(index);
  }

  /// Adds a new row to the table.
  void handleAddRow() {
    controller.append(new Todo(name: todoName, createdAt: new DateTime.now()));
    todoName = '';
  }

  /// Shuffles the rows currently in the table.
  void handleShuffle() {
    controller.setState((rows) {
      rows.shuffle();
    });
  }

  /// Adds 100 todos at once
  void handleAdd100() {
    var newTodos = new List.generate(100, (_) => new Todo.random());
    controller.appendAll(newTodos);
  }

  void completeSelected() {
    for (var todo in selected) {
      todo.isDone = true;
    }
    selected.clear();
  }

  void updateSelected(bool value, Todo todo) {
    if (value) {
      selected.add(todo);
    } else {
      selected.remove(todo);
    }
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
      createdAt: new DateTime.now(),
    );
  }
}
