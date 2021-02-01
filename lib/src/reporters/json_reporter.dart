import 'dart:convert';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:source_span/source_span.dart';

import '../models/context_message.dart';
import '../models/file_report.dart';
import '../models/issue.dart';
import '../models/metric_value.dart';
import '../models/replacement.dart';
import '../models/report.dart';
import 'reporter.dart';

/// Machine-readable report in JSON format
@immutable
class JsonReporter implements Reporter {
  final IOSink _output;

  const JsonReporter(this._output);

  @override
  void report(Iterable<FileReport> records) {
    if (records?.isEmpty ?? true) {
      return;
    }

    final encodedReport =
        json.encode({'records': records.map(_analysisRecordToJson).toList()});

    _output.write(encodedReport);
  }

  Map<String, Object> _analysisRecordToJson(FileReport report) => {
        'path': report.relativePath,
        'classes': _reportReports(report.classes),
        'functions': _reportReports(report.functions),
        'issues': _reportIssues(report.issues),
        'antiPatternCases': _reportIssues(report.antiPatternCases),
      };

  Map<String, Map<String, Object>> _reportReports(
    Map<String, Report> classes,
  ) =>
      classes.map((key, value) => MapEntry(key, {
            'location': _reportLocation(value.location),
            'metrics': _reportMetrics(value.metrics),
          }));

  List<Map<String, Object>> _reportIssues(Iterable<Issue> issues) => issues
      .map((issue) => {
            'ruleId': issue.ruleId,
            'documentation': issue.documentation.toString(),
            'location': _reportLocation(issue.location),
            'severity': issue.severity.toString(),
            'message': issue.message,
            if (issue.verboseMessage?.isNotEmpty ?? false)
              'verboseMessage': issue.verboseMessage,
            if (issue.suggestion != null)
              'suggestion': _reportReplacement(issue.suggestion),
          })
      .toList();

  Map<String, Object> _reportLocation(SourceSpan location) => {
        'start': _reportSourceLocation(location.start),
        'end': _reportSourceLocation(location.end),
        'text': location.text,
      };

  List<Map<String, Object>> _reportMetrics(
    Iterable<MetricValue<num>> metrics,
  ) =>
      metrics
          .map((metric) => {
                'metricsId': metric.metricsId,
                'value': metric.value,
                'level': metric.level.toString(),
                'comment': metric.comment,
                if (metric.recommendation != null)
                  'recommendation': metric.recommendation,
                if (metric.context != null)
                  'context': _reportContextMessages(metric.context),
              })
          .toList();

  Map<String, Object> _reportSourceLocation(SourceLocation location) => {
        'offset': location.offset,
        'line': location.line,
        'column': location.column,
      };

  List<Map<String, Object>> _reportContextMessages(
    Iterable<ContextMessage> messages,
  ) =>
      messages
          .map((message) => {
                'message': message.message,
                'location': _reportLocation(message.location),
              })
          .toList();

  Map<String, String> _reportReplacement(Replacement replacement) => {
        'comment': replacement.comment,
        'replacement': replacement.replacement,
      };
}
