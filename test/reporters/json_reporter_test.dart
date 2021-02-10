@TestOn('vm')
import 'dart:convert';
import 'dart:io';

import 'package:code_checker/rules.dart';
import 'package:code_checker/src/models/context_message.dart';
import 'package:code_checker/src/models/file_report.dart';
import 'package:code_checker/src/models/issue.dart';
import 'package:code_checker/src/models/metric_value.dart';
import 'package:code_checker/src/models/metric_value_level.dart';
import 'package:code_checker/src/models/report.dart';
import 'package:code_checker/src/reporters/json_reporter.dart';
import 'package:mockito/mockito.dart';
import 'package:source_span/source_span.dart';
import 'package:test/test.dart';

class IOSinkMock extends Mock implements IOSink {}

const _src1Path = 'lib/src/model/source1.dart';
const _src2Path = 'lib/src/service/source1.dart';

final _class1Report = Report(
  location: SourceSpan(SourceLocation(0), SourceLocation(10), 'class body'),
  metrics: const [
    MetricValue<int>(
      metricsId: 'id',
      value: 0,
      level: MetricValueLevel.none,
      comment: 'metric comment',
    ),
  ],
);

final _function1Report = Report(
  location:
      SourceSpan(SourceLocation(0), SourceLocation(16), 'constructor body'),
  metrics: const [
    MetricValue<int>(
      metricsId: 'id',
      value: 10,
      level: MetricValueLevel.alarm,
      comment: 'metric comment',
      recommendation: 'refactoring',
    ),
  ],
);
final _function2Report = Report(
  location: SourceSpan(SourceLocation(0), SourceLocation(11), 'method body'),
  metrics: [
    MetricValue<int>(
      metricsId: 'id2',
      value: 1,
      level: MetricValueLevel.none,
      comment: 'metric comment',
      context: [
        ContextMessage(
          message: 'begin of method',
          location: SourceSpan(SourceLocation(0), SourceLocation(6), 'method'),
        ),
      ],
    ),
  ],
);

final _function3Report = Report(
  location:
      SourceSpan(SourceLocation(0), SourceLocation(20), 'simple function body'),
  metrics: const [
    MetricValue<int>(
      metricsId: 'id',
      value: 5,
      level: MetricValueLevel.warning,
      comment: 'metric comment',
    ),
  ],
);

final _issueReport = Issue(
  ruleId: 'id',
  documentation: Uri.parse('https://documentation.com'),
  location:
      SourceSpan(SourceLocation(0), SourceLocation(20), 'simple function body'),
  severity: Severity.warning,
  message: 'simple message',
  verboseMessage: 'verbose message',
);

final _testReport = [
  FileReport(
    path: _src1Path,
    relativePath: _src1Path,
    classes: {'class': _class1Report},
    functions: {
      'class.constructor': _function1Report,
      'class.method': _function2Report,
    },
    issues: const [],
    antiPatternCases: const [],
  ),
  FileReport(
    path: _src2Path,
    relativePath: _src2Path,
    classes: const {},
    functions: {'function': _function3Report},
    issues: [_issueReport],
    antiPatternCases: const [],
  ),
];

void main() {
  test('JsonReporter reports in json format', () {
    final output = IOSinkMock();

    JsonReporter(output).report(_testReport);

    final report =
        json.decode(verify(output.write(captureAny)).captured.first as String)
            as Map<String, Object>;

    expect(report, contains('records'));
    expect(report['records'] as Iterable, hasLength(2));

    final recordFirst =
        (report['records'] as Iterable).first as Map<String, Object>;
    expect(recordFirst, containsPair('path', _src1Path));

    final recordLast =
        (report['records'] as Iterable).last as Map<String, Object>;
    expect(recordLast, containsPair('path', _src2Path));
    expect(
      recordLast['issues'],
      equals([
        {
          'ruleId': 'id',
          'documentation': 'https://documentation.com',
          'location': {
            'start': {'offset': 0, 'line': 0, 'column': 0},
            'end': {'offset': 20, 'line': 0, 'column': 20},
            'text': 'simple function body',
          },
          'severity': 'warning',
          'message': 'simple message',
          'verboseMessage': 'verbose message',
        },
      ]),
    );

    output.close();
  });
}
