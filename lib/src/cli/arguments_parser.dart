import 'package:args/args.dart';

import '../metrics_factory.dart';

const usageHeader = 'Usage: checker [arguments] <directories>';

const helpFlagName = 'help';

ArgParser argumentsParser() {
  final parser = ArgParser()..addSeparator('');

  _appendHelpOption(parser);
  parser.addSeparator('');
  _appendMetricsThresholdOptions(parser);

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

void _appendMetricsThresholdOptions(ArgParser parser) {
  for (final metric in allMetrics) {
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
