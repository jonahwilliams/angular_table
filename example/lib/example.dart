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
  ],
  providers: const [
    materialProviders,
  ],
  preserveWhitespace: false,
)
class AppComponent {
  final controller = new TableController<String>.from(const [
    'This is a todo',
    'this is another todo',
    'Finish the table',
  ]);
  String text = '';

  /// Deletes the row at [index]
  void handleDeleteRow(int index) {
    controller.removeRow(index);
  }

  /// Adds a new row to the table.
  void handleAddRow() {
    controller.append(text);
    text = '';
  }

  /// Shuffles the rows currently in the table.
  void handleShuffle() {
    controller.setState((rows) {
      rows.shuffle();
    });
  }

  /// Adds 100 todos at once
  void handleAdd100() {
    var gen = new math.Random();
    var result = <String>[];
    result.length = 100;
    for (var i = 0; i < 100; i++) {
      result[i] = new String.fromCharCodes([
        gen.nextInt(127) + 33,
        gen.nextInt(127) + 33,
        gen.nextInt(127) + 33,
        gen.nextInt(127) + 33,
        gen.nextInt(127) + 33,
        gen.nextInt(127) + 33,
      ]);
    }
    controller.appendAll(result);
  }
}
