@TestOn('vm')
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/src/context/context_root.dart' as analyzer_internal;
import 'package:analyzer/src/dart/analysis/driver.dart' as analyzer_internal;
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:code_checker/src/analyzer_plugin/plugin_utils.dart';
import 'package:code_checker/src/config/config.dart';
import 'package:code_checker/src/models/issue.dart';
import 'package:code_checker/src/models/metric_value_level.dart';
import 'package:code_checker/src/models/severity.dart';
import 'package:glob/glob.dart';
import 'package:mockito/mockito.dart';
import 'package:source_span/source_span.dart';
import 'package:test/test.dart';

class AnalysisDriverMock extends Mock
    implements analyzer_internal.AnalysisDriver {}

class AnalysisResultMock extends Mock implements AnalysisResult {}

// ignore: avoid_implementing_value_types
class ContextRootMock extends Mock implements analyzer_internal.ContextRoot {}

class ResourceProviderMock extends Mock implements ResourceProvider {}

class FileMock extends Mock implements File {}

void main() {
  group('analyzer plugin utils', () {
    test('fixesFromIssue converts issue to AnalysisErrorFixes', () {
      const sourcePath = 'source_file.dart';
      const sampleCode = 'sample code';
      const offset = 5;
      const length = sampleCode.length;
      const end = offset + length;
      const line = 2;
      const column = 1;
      const ruleId = 'rule-id';
      const patternDocumentationUrl = 'https://www.example.com';
      const issueMessage = 'diagnostic message';
      const issueRecommendationMessage = 'diagnostic recommendation message';

      final startLocation = SourceLocation(
        offset,
        sourceUrl: Uri.parse(sourcePath),
        line: line,
        column: column,
      );

      final endLocation = SourceLocation(end, sourceUrl: Uri.parse(sourcePath));

      final issue = Issue(
        ruleId: ruleId,
        documentation: Uri.parse(patternDocumentationUrl),
        location: SourceSpan(startLocation, endLocation, sampleCode),
        severity: Severity.warning,
        message: issueMessage,
        verboseMessage: issueRecommendationMessage,
      );

      final fixes = fixesFromIssue(issue, null);

      expect(fixes.error.severity, equals(AnalysisErrorSeverity.WARNING));
      expect(fixes.error.type, equals(AnalysisErrorType.LINT));
      expect(fixes.error.location.file, equals(sourcePath));
      expect(fixes.error.location.offset, equals(offset));
      expect(fixes.error.location.length, equals(length));
      expect(fixes.error.location.startLine, equals(line));
      expect(fixes.error.location.startColumn, equals(column));
      expect(fixes.error.message, equals(issueMessage));
      expect(fixes.error.code, equals(ruleId));
      expect(fixes.error.correction, equals(issueRecommendationMessage));
      expect(fixes.error.url, equals(patternDocumentationUrl));
      expect(fixes.error.contextMessages, isNull);
      expect(fixes.error.hasFix, isFalse);
      expect(fixes.fixes, isEmpty);
    });

    test('isExcluded checks exclude or not analysis result', () {
      final analysisResultMock = AnalysisResultMock();
      when(analysisResultMock.path).thenReturn('lib/src/example.dart');

      expect(
        isExcluded(
          source: analysisResultMock,
          excludes: [Glob('test/**.dart'), Glob('lib/src/**.dart')],
        ),
        isTrue,
      );
      expect(
        isExcluded(
          source: analysisResultMock,
          excludes: [Glob('test/**.dart'), Glob('bin/**.dart')],
        ),
        isFalse,
      );
    });

    group('isSupported returns', () {
      AnalysisResultMock analysisResultMock;

      setUp(() {
        analysisResultMock = AnalysisResultMock();
      });

      test('false on analysis result without path', () {
        expect(isSupported(analysisResultMock), isFalse);
      });
      test('true on dart files', () {
        when(analysisResultMock.path).thenReturn('lib/src/example.dart');

        expect(isSupported(analysisResultMock), isTrue);
      });
      test('false on generated dart files', () {
        when(analysisResultMock.path).thenReturn('lib/src/example.g.dart');

        expect(isSupported(analysisResultMock), isFalse);
      });
    });

    test('pluginConfig constructs PluginConfig from different sources', () {
      final config = pluginConfig(
        const Config(
          excludePatterns: ['test/resources/**'],
          excludeForMetricsPatterns: ['test/**'],
          metrics: {
            'maximum-nesting-level': '5',
            'number-of-methods': '10',
            'weight-of-class': '0.33',
          },
          rules: {'newline-before-return': {}},
        ),
        ['.dart_tool/**', 'packages/**'],
        '/home/user/project',
      );

      expect(
        config.globalExclude.map((exclude) => exclude.pattern),
        equals([
          '/home/user/project/.dart_tool/**',
          '/home/user/project/packages/**',
          '/home/user/project/test/resources/**',
        ]),
      );
      expect(
        config.codeRules.map((rule) => rule.id),
        equals(['newline-before-return']),
      );
      expect(
        config.classesMetrics.map((metric) => metric.id),
        equals(['number-of-methods', 'weight-of-class']),
      );
      expect(
        config.methodsMetrics.map((metric) => metric.id),
        equals(['maximum-nesting-level']),
      );
      expect(
        config.metricsExclude.map((exclude) => exclude.pattern),
        equals(['/home/user/project/test/**']),
      );
    });

    test(
      'readAnalysisOptions constructs AnalysisOptions from driver context',
      () {
        const analysisOptionsPath = 'analysis_options.yaml';

        expect(readAnalysisOptions(null), isNull);

        final driver = AnalysisDriverMock();
        expect(readAnalysisOptions(driver), isNull);

        final contextRoot = ContextRootMock();
        when(driver.contextRoot).thenReturn(contextRoot);
        expect(readAnalysisOptions(driver), isNull);

        when(contextRoot.optionsFilePath).thenReturn('');
        expect(readAnalysisOptions(driver), isNull);

        when(contextRoot.optionsFilePath).thenReturn(analysisOptionsPath);
        expect(readAnalysisOptions(driver), isNull);

        final resourceProvider = ResourceProviderMock();
        when(driver.resourceProvider).thenReturn(resourceProvider);
        expect(readAnalysisOptions(driver), isNull);

        final file = FileMock();
        when(resourceProvider.getFile(analysisOptionsPath)).thenReturn(file);
        expect(readAnalysisOptions(driver), isNull);

        when(file.exists).thenReturn(true);
        expect(readAnalysisOptions(driver), isNotNull);
      },
    );

    test(
      'severityFromIssueSeverity converts Severity to AnalysisErrorSeverity',
      () {
        expect(
          Severity.values.map(severityFromIssueSeverity),
          equals([
            AnalysisErrorSeverity.ERROR,
            AnalysisErrorSeverity.WARNING,
            AnalysisErrorSeverity.INFO,
            AnalysisErrorSeverity.INFO,
            AnalysisErrorSeverity.INFO,
          ]),
        );
      },
    );

    test(
      'severityFromMetricValueLevel converts MetricValueLevel to AnalysisErrorSeverity',
      () {
        expect(
          MetricValueLevel.values.map(severityFromMetricValueLevel),
          equals([
            AnalysisErrorSeverity.INFO,
            AnalysisErrorSeverity.INFO,
            AnalysisErrorSeverity.INFO,
            AnalysisErrorSeverity.WARNING,
          ]),
        );
      },
    );
  });
}
