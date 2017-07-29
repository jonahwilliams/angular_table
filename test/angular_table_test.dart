// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@Tags(const ['codegen'])
@TestOn('browser')
import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_table/angular_table.dart';
import 'package:angular_test/angular_test.dart';
import 'package:test/test.dart';
import 'package:pageloader/objects.dart';

const expectedRows = const ['a', 'b', 'c'];

@AngularEntrypoint()
void main() {
  group('TableController', () {
    NgTestBed testBed;
    NgTestFixture testFixture;
    TestPO pageObject;

    setUp(() async {
      testBed = new NgTestBed<TestComponent>();
    });

    /// Sets up the component test by first initializing the the component with
    /// [initialData] and then optionally calling an update method.
    ///
    /// the [pageObject] must be resolved after any DOM changes, or it won't
    /// be up to date (unless you use Lazy<T>).
    Future<Null> setUpComponent(List<String> initialData,
        [void Function(TestComponent) update]) async {
      testFixture = await testBed.create(
          beforeChangeDetection: (TestComponent component) {
        component.data = initialData;
      });
      if (update != null) {
        await testFixture.update(update);
      }
      pageObject = await testFixture.resolvePageObject<TestPO>(TestPO);
    }

    test('renders the correct number of initial rows', () async {
      await setUpComponent(expectedRows);

      expect(await pageObject.first, ['0', '1', '2']);
      expect(await pageObject.second, expectedRows);
    });

    test('prepends a single row to the start', () async {
      await setUpComponent(expectedRows, (component) {
        component.controller.prepend('z');
      });

      expect(await pageObject.first, ['0', '1', '2', '3']);
      expect(await pageObject.second, ['z', 'a', 'b', 'c']);
    });

    test('prepends a single row to the start in an empty table', () async {
      await setUpComponent(const [], (component) {
        component.controller.prepend('z');
      });

      expect(await pageObject.first, ['0']);
      expect(await pageObject.second, ['z']);
    });

    test('prepends multiple rows to the start', () async {
      const expectedPrepend = const ['z', 'y', 'x'];
      await setUpComponent(expectedRows, (component) {
        component.controller.prependAll(expectedPrepend);
      });

      expect(await pageObject.first, ['0', '1', '2', '3', '4', '5']);
      expect(await pageObject.second, ['z', 'y', 'x', 'a', 'b', 'c']);
    });

    test('prepends multiple rows to the start in an empty table', () async {
      const expectedPrepend = const ['z', 'y', 'x'];
      await setUpComponent(const [], (component) {
        component.controller.prependAll(expectedPrepend);
      });

      expect(await pageObject.first, ['0', '1', '2']);
      expect(await pageObject.second, ['z', 'y', 'x']);
    });

    test('appends a single row to the end', () async {
      await setUpComponent(expectedRows, (TestComponent component) {
        component.controller.append('z');
      });

      expect(await pageObject.first, ['0', '1', '2', '3']);
      expect(await pageObject.second, ['a', 'b', 'c', 'z']);
    });

    test('appends a single row to the end in an empty table', () async {
      await setUpComponent(const [], (TestComponent component) {
        component.controller.append('z');
      });

      expect(await pageObject.first, ['0']);
      expect(await pageObject.second, ['z']);
    });

    test('appends multiple rows to the end', () async {
      await setUpComponent(expectedRows, (component) {
        component.controller.appendAll(['z', 'y', 'x']);
      });

      expect(await pageObject.first, ['0', '1', '2', '3', '4', '5']);
      expect(await pageObject.second, ['a', 'b', 'c', 'z', 'y', 'x']);
    });

    test('appends multiple rows to the end in an empty table', () async {
      await setUpComponent(const [], (component) {
        component.controller.appendAll(['z', 'y', 'x']);
      });

      expect(await pageObject.first, ['0', '1', '2']);
      expect(await pageObject.second, ['z', 'y', 'x']);
    });

    test('removes a row at a specified index', () async {
      await setUpComponent(expectedRows, (component) {
        component.controller.removeRow(1);
      });

      expect(await pageObject.first, ['0', '1']);
      expect(await pageObject.second, ['a', 'c']);
    });

    test('inserts a row at a specified index', () async {
      await setUpComponent(expectedRows, (component) {
        component.controller.insertRow(1, 'z');
      });

      expect(await pageObject.first, ['0', '1', '2', '3']);
      expect(await pageObject.second, ['a', 'z', 'b', 'c']);
    });

    test('clears the table of all rows', () async {
      await setUpComponent(expectedRows, (component) {
        component.controller.clear();
      });

      expect(await pageObject.first, isEmpty);
      expect(await pageObject.second, isEmpty);
    });

    tearDown(disposeAnyRunningTest);
  });
}

@Component(
  selector: 'test',
  template: '''
    <div *ngTable="let data of controller; let i = index">
        <div class="col-1">{{i}}</div>
        <div class="col-2">{{data}}</div>
    </div>
  ''',
  directives: const [
    AngularTableDirective,
  ],
)
class TestComponent implements OnInit {
  @Input()
  List<String> data;

  TableController controller;

  @override
  void ngOnInit() {
    controller = new TableController.from(data);
  }
}

@EnsureTag('test')
class TestPO {
  @ByClass('col-1')
  List<PageLoaderElement> firstColumn;

  @ByClass('col-2')
  List<PageLoaderElement> secondColumn;

  Future<List<Object>> get first async {
    return await Future.wait((await firstColumn).map((x) => x.innerText));
  }

  Future<List<Object>> get second async {
    return await Future.wait((await secondColumn).map((x) => x.innerText));
  }
}
