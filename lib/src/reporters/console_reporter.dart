import 'dart:io';

import 'package:ansicolor/ansicolor.dart';
import 'package:meta/meta.dart';

import '../models/file_report.dart';
import '../models/issue.dart';
import '../models/metric_value.dart';
import '../models/metric_value_level.dart';
import '../models/report.dart';
import '../models/severity.dart';
import '../utils/metric_utils.dart';
import '../utils/string_extension.dart';
import 'reporter.dart';

final _colorPens = {
  MetricValueLevel.alarm: AnsiPen()..red(bold: true),
  MetricValueLevel.warning: AnsiPen()..yellow(bold: true),
  MetricValueLevel.noted: AnsiPen()..blue(),
  MetricValueLevel.none: AnsiPen()..green(),
};

final _severityPen = {
  Severity.error: AnsiPen()..red(bold: true),
  Severity.warning: AnsiPen()..yellow(bold: true),
  Severity.performance: AnsiPen()..cyan(),
  Severity.style: AnsiPen()..blue(),
};

/// Human-readable terminal reporter
@immutable
class ConsoleReporter implements Reporter {
  final IOSink _output;

  const ConsoleReporter(this._output);

  @override
  void report(Iterable<FileReport> records) {
    if (records?.isEmpty ?? true) {
      return;
    }

    for (final file in records) {
      final reportedLines = [
        ..._reportIssues([...file.issues, ...file.antiPatternCases]),
        ..._reportMetrics({...file.classes, ...file.functions}),
      ];

      if (reportedLines.isNotEmpty) {
        _output.writeln('${file.relativePath}:');
        reportedLines.forEach(_output.writeln);
        _output.writeln('');
      }
    }
  }

  Iterable<String> _reportIssues(Iterable<Issue> issues) => (issues.toList()
        ..sort((a, b) =>
            a.location.start.offset.compareTo(b.location.start.offset)))
      .map((issue) =>
          '${_severityPen[issue.severity](issue.severity.toString().capitalize().padRight(8))}${[
            issue.message,
            '${issue.location.start.line}:${issue.location.start.column}',
            issue.ruleId,
          ].join(' : ')}');

  Iterable<String> _reportMetrics(Map<String, Report> reports) =>
      (reports.entries.toList()
            ..sort((a, b) => a.value.location.start.offset
                .compareTo(b.value.location.start.offset)))
          .expand((entry) {
        final source = entry.key;
        final report = entry.value;

        final reportLevel = report.metricsLevel;
        if (isReportLevel(reportLevel)) {
          final violations = [
            for (final metric in report.metrics)
              if (_isNeedToReport(metric)) _report(metric),
          ];

          return [
            '${_colorPens[reportLevel](reportLevel.toString().capitalize()?.padRight(8))}$source - ${violations.join(', ')}',
          ];
        }

        return [];
      });

  bool _isNeedToReport(MetricValue metric) =>
      metric.level > MetricValueLevel.none;

  String _report(MetricValue metric) =>
      '${metric.documentation.shortName}: ${_colorPens[metric.level]('${metric.value.toInt()}')}';
}
