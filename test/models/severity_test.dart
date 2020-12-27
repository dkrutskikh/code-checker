import 'package:code_checker/src/models/severity.dart';
@TestOn('vm')
import 'package:test/test.dart';

void main() {
  test('Severity fromJson constructs object from string', () {
    expect(
      ['StyLe', 'wArnInG', 'erROr', '', null].map(Severity.fromJson),
      equals([
        Severity.style,
        Severity.warning,
        Severity.error,
        Severity.none,
        null,
      ]),
    );
  });
}
