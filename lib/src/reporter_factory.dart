import 'dart:io';

import 'package:meta/meta.dart';

import 'cli/arguments_parser.dart';
import 'reporters/console_reporter.dart';
import 'reporters/json_reporter.dart';
import 'reporters/reporter.dart';

final _implementedReports = <String, Reporter Function(IOSink output)>{
  consoleReporter: (output) => ConsoleReporter(output),
  jsonReporter: (output) => JsonReporter(output),
};

Reporter reporter({@required String name, @required IOSink output}) {
  final constructor = name != null ? _implementedReports[name] : null;

  return constructor != null ? constructor(output) : null;
}
