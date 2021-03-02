@TestOn('vm')
import 'package:code_checker/src/cli/arguments_parser.dart';
import 'package:test/test.dart';

const _usage = '\n'
    '-h, --help                                        Print this usage information.\n'
    '\n'
    '\n'
    '-r, --reporter=<console>                          The format of the output of the analysis\n'
    '                                                  [console (default), json]\n'
    '\n'
    '\n'
    '    --lines-of-code=<100>                         Lines of Code threshold\n'
    '    --maximum-nesting-level=<5>                   Maximum Nesting Level threshold\n'
    '    --number-of-methods=<10>                      Number of Methods threshold\n'
    '    --number-of-parameters=<4>                    Number of Parameters threshold\n'
    '    --weight-of-class=<0.33>                      Weight Of a Class threshold\n'
    '\n'
    '\n'
    '    --root-folder=<./>                            Root folder\n'
    '                                                  (defaults to current directory)\n'
    '    --exclude=<{/**.g.dart,/**.template.dart}>    File paths in Glob syntax to be exclude\n'
    '                                                  (defaults to "{/**.g.dart,/**.template.dart}")';

void main() {
  test('argumentsParser().usage returns human readable help', () {
    expect(
      argumentsParser().usage.replaceAll(
            RegExp('defaults to "(.*?)code-checker"'),
            'defaults to current directory',
          ),
      equals(_usage),
    );
  });
}
