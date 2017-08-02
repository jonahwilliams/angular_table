// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library angular_table.table;

import 'package:angular/angular.dart';
import 'dart:collection';

part 'table_controller.dart';
part 'stateful_table_controller.dart';
part 'table_directive.dart';

/// Allows defining a custom equality function for classes which don't override
/// `==`.
typedef Equality<T> = bool Function(T left, T right);

Equality<Object> defaultEqulity = identical;
