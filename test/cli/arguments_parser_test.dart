@TestOn('vm')
import 'package:code_checker/src/cli/arguments_parser.dart';
import 'package:test/test.dart';

const _usage = '\n'
    '-h, --help                      Print this usage information.\n'
    '\n'
    '\n'
    '    --number-of-methods=<10>    Number of Methods threshold\n'
    '    --weight-of-class=<0.33>    Weight Of a Class threshold';

void main() {
  test('argumentsParser().usage returns human readable help', () {
    expect(argumentsParser().usage, equals(_usage));
  });
}
