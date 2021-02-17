import 'dart:io';

import 'package:args/args.dart';

import '../metrics_factory.dart';

const usageHeader = 'Usage: checker [arguments] <directories>';

const helpFlagName = 'help';
const reporterName = 'reporter';
const excludedName = 'exclude';
const rootFolderName = 'root-folder';

const consoleReporter = 'console';
const jsonReporter = 'json';

ArgParser argumentsParser() {
  final parser = ArgParser()..addSeparator('');

  _appendHelpOption(parser);
  parser.addSeparator('');
  _appendReporterOption(parser);
  parser.addSeparator('');
  _appendMetricsThresholdOptions(parser);
  parser.addSeparator('');
  _appendRootOption(parser);
  _appendExcludeOption(parser);

  return parser;
}

void _appendHelpOption(ArgParser parser) {
  parser.addFlag(
    helpFlagName,
    abbr: 'h',
    help: 'Print this usage information.',
    negatable: false,
  );
}

void _appendReporterOption(ArgParser parser) {
  parser.addOption(
    reporterName,
    abbr: 'r',
    help: 'The format of the output of the analysis',
    valueHelp: consoleReporter,
    allowed: [consoleReporter, jsonReporter],
    defaultsTo: consoleReporter,
  );
}

void _appendMetricsThresholdOptions(ArgParser parser) {
  for (final metric in metrics(config: {})) {
    parser.addOption(
      metric.id,
      help: '${metric.documentation.name} threshold',
      valueHelp: '${metric.threshold}',
      // ignore: avoid_types_on_closure_parameters
      callback: (String i) {
        if (i != null && int.tryParse(i) == null) {
          print("'$i' invalid value for argument ${metric.documentation.name}");
        }
      },
    );
  }
}

void _appendRootOption(ArgParser parser) {
  parser.addOption(
    rootFolderName,
    help: 'Root folder',
    valueHelp: './',
    defaultsTo: Directory.current.path,
  );
}

void _appendExcludeOption(ArgParser parser) {
  parser.addOption(
    excludedName,
    help: 'File paths in Glob syntax to be exclude',
    valueHelp: '{/**.g.dart,/**.template.dart}',
    defaultsTo: '{/**.g.dart,/**.template.dart}',
  );
}
