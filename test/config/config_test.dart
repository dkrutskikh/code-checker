@TestOn('vm')
import 'package:code_checker/src/config/analysis_options.dart';
import 'package:code_checker/src/config/config.dart';
import 'package:test/test.dart';

const _options = AnalysisOptions({
  'include': 'package:pedantic/analysis_options.yaml',
  'analyzer': {
    'exclude': ['test/resources/**'],
    'plugins': ['code_checker'],
    'strong-mode': {'implicit-casts': false, 'implicit-dynamic': false},
  },
  'code_checker': {
    'anti-patterns': {
      'anti-pattern-id1': true,
      'anti-pattern-id2': false,
      'anti-pattern-id3': true,
    },
    'metrics': {
      'metric-id1': '5',
      'metric-id2': '10',
      'metric-id3': '5',
      'metric-id4': '0',
    },
    'metrics-exclude': ['test/**', 'examples/**'],
    'rules': {'rule-id1': false, 'rule-id2': true, 'rule-id3': true},
  },
});

void main() {
  group('Config.fromAnalysisOptions constructs instance from passed', () {
    test('empty options', () {
      final config = Config.fromAnalysisOptions(const AnalysisOptions({}));

      expect(config.excludePatterns, isEmpty);
      expect(config.excludeForMetricsPatterns, isEmpty);
      expect(config.metrics, isEmpty);
    });

    test('data', () {
      final config = Config.fromAnalysisOptions(_options);

      expect(config.excludePatterns, equals(['test/resources/**']));
      expect(
        config.excludeForMetricsPatterns,
        equals(['test/**', 'examples/**']),
      );
      expect(
        config.metrics,
        equals({
          'metric-id1': '5',
          'metric-id2': '10',
          'metric-id3': '5',
          'metric-id4': '0',
        }),
      );
    });
  });
}
