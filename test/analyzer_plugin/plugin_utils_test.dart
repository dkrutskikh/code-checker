@TestOn('vm')
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/src/context/context_root.dart' as analyzer_internal;
import 'package:analyzer/src/dart/analysis/driver.dart' as analyzer_internal;
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:code_checker/src/analyzer_plugin/plugin_utils.dart';
import 'package:code_checker/src/config/config.dart';
import 'package:code_checker/src/models/metric_value_level.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class AnalysisDriverMock extends Mock
    implements analyzer_internal.AnalysisDriver {}

// ignore: avoid_implementing_value_types
class ContextRootMock extends Mock implements analyzer_internal.ContextRoot {}

class ResourceProviderMock extends Mock implements ResourceProvider {}

class FileMock extends Mock implements File {}

void main() {
  group('analyzer plugin utils', () {
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
