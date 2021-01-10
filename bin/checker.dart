import 'dart:io';

import 'package:code_checker/src/cli/arguments_parser.dart';
import 'package:code_checker/src/cli/arguments_validation.dart';
import 'package:code_checker/src/cli/arguments_validation_exceptions.dart';

final _parser = argumentsParser();

Future<void> main(List<String> args) async {
  try {
    final arguments = _parser.parse(args);

    if (arguments[helpFlagName] as bool) {
      _showUsageAndExit(0);
    }

    validateArguments(arguments);
  } on FormatException catch (e) {
    print('${e.message}\n');
    _showUsageAndExit(1);
  } on InvalidArgumentException catch (e) {
    print('${e.message}\n');
    _showUsageAndExit(1);
  }
}

void _showUsageAndExit(int exitCode) {
  print(usageHeader);
  print(_parser.usage);

  exit(exitCode);
}
