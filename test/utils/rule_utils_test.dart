@TestOn('vm')
import 'package:code_checker/src/models/severity.dart';
import 'package:code_checker/src/utils/rule_utils.dart';
import 'package:test/test.dart';

void main() {
  test('readSeverity returns a Severity from Map based config', () {
    expect(
      [
        {'severity': 'ERROR'},
        {'severity': 'wArnInG'},
        {'severity': 'performance'},
        {'severity': ''},
        {'': null},
      ].map((data) => readSeverity(data, Severity.style)),
      equals([
        Severity.error,
        Severity.warning,
        Severity.performance,
        Severity.none,
        Severity.style,
      ]),
    );
  });
}
