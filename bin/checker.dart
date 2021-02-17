import 'dart:io';

import 'package:args/args.dart';
import 'package:code_checker/checker.dart';
import 'package:code_checker/metrics.dart';
import 'package:code_checker/reporters.dart';
import 'package:code_checker/src/cli/arguments_parser.dart';
import 'package:code_checker/src/cli/arguments_validation.dart';
import 'package:code_checker/src/cli/arguments_validation_exceptions.dart';
import 'package:path/path.dart' as p;

final _parser = argumentsParser();

Future<void> main(List<String> args) async {
  try {
    final arguments = _parser.parse(args);

    if (arguments[helpFlagName] as bool) {
      _showUsageAndExit(0);
    }

    validateArguments(arguments);
    await _runAnalysis(arguments);
  } on FormatException catch (e) {
    print('${e.message}\n');
    _showUsageAndExit(1);
  } on InvalidArgumentException catch (e) {
    print('${e.message}\n');
    _showUsageAndExit(1);
  }
}

Future<void> _runAnalysis(ArgResults arguments) async {
  final rootFolder = arguments[rootFolderName] as String;

  final analysisOptionsFile =
      File(p.absolute(rootFolder, analysisOptionsFileName));

  final options = await analysisOptionsFromFile(analysisOptionsFile);

  final store = ReportsStore.store();
  final checker = Checker(
    store,
    Config.fromAnalysisOptions(options).merge(_configFromArgs(arguments)),
  );
  final runner = Runner(checker, store, arguments.rest, rootFolder);
  await runner.run();

  reporter(name: arguments[reporterName] as String, output: stdout)
      ?.report(runner.results());
}

Config _configFromArgs(ArgResults arguments) => Config(
      excludePatterns: [arguments[excludedName] as String],
      excludeForMetricsPatterns: const [],
      metrics: {
        for (final metric in metrics(config: {}))
          if (arguments.wasParsed(metric.id)) metric.id: arguments[metric.id],
      },
      rules: const {},
    );

void _showUsageAndExit(int exitCode) {
  print(usageHeader);
  print(_parser.usage);

  exit(exitCode);
}
