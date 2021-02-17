@TestOn('vm')
import 'dart:io';

import 'package:code_checker/src/reporter_factory.dart';
import 'package:code_checker/src/reporters/console_reporter.dart';
import 'package:code_checker/src/reporters/json_reporter.dart';
import 'package:test/test.dart';

void main() {
  test('reporter returns only required reporter', () {
    expect(reporter(name: null, output: stdout), isNull);
    expect(reporter(name: '', output: stdout), isNull);
    expect(reporter(name: 'console', output: stdout), isA<ConsoleReporter>());
    expect(reporter(name: 'json', output: stdout), isA<JsonReporter>());
  });
}
