import 'dart:isolate';

import 'package:code_checker/analyzer_plugin.dart';

void main(List<String> args, SendPort sendPort) {
  start(args, sendPort);
}
