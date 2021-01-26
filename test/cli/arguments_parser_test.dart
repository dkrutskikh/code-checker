@TestOn('vm')
import 'package:code_checker/src/cli/arguments_parser.dart';
import 'package:test/test.dart';

const _usage = '\n'
    '-h, --help                         Print this usage information.\n'
    '\n'
    '\n'
    '    --maximum-nesting-level=<5>    Maximum Nesting Level threshold\n'
    '    --number-of-methods=<10>       Number of Methods threshold\n'
    '    --weight-of-class=<0.33>       Weight Of a Class threshold\n'
    '\n'
    '\n'
    '    --root-folder=<./>             Root folder\n'
    '                                   (defaults to current directory)';

void main() {
  test('argumentsParser().usage returns human readable help', () {
    expect(
      argumentsParser().usage.replaceAll(
            RegExp('defaults to "(.*?)"'),
            'defaults to current directory',
          ),
      equals(_usage),
    );
  });
}
