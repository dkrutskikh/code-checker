// @dart=2.8

import '../models/file_report.dart';

/// Abstract reporter interface. Use [Runner] to get analysis info to report
abstract class Reporter {
  void report(Iterable<FileReport> records);

  const Reporter();
}
