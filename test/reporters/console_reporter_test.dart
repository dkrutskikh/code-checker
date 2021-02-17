@TestOn('vm')
import 'dart:io';

import 'package:ansicolor/ansicolor.dart';
import 'package:code_checker/src/reporters/console_reporter.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'report.dart';

class IOSinkMock extends Mock implements IOSink {}

void main() {
  group('ConsoleReporter reports in plaint text format', () {
    IOSinkMock output;

    setUp(() {
      ansiColorDisabled = false;
      output = IOSinkMock();
    });

    test('empty report', () {
      ConsoleReporter(output).report([]);

      verifyNever(output.write(captureAny));
    });

    test('complex report', () {
      ConsoleReporter(output).report(testReport);

      final report = verify(output.writeln(captureAny)).captured.cast<String>();

      expect(
        report,
        equals([
          'lib/src/model/source1.dart:',
          '\x1B[38;5;9mAlarm   \x1B[0mclass.constructor - MTR2: \x1B[38;5;9m10\x1B[0m',
          '',
          'lib/src/service/source1.dart:',
          '\x1B[38;5;11mWarning \x1B[0msimple message : 0:0 : id',
          '\x1B[38;5;11mWarning \x1B[0mfunction - MTR4: \x1B[38;5;11m5\x1B[0m',
          '',
        ]),
      );

      output.close();
    });
  });
}
