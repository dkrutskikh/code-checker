import 'package:glob/glob.dart';
import 'package:meta/meta.dart';

import '../metrics/metric.dart';
import '../rules/rule.dart';

@immutable
class PluginConfig {
  final Iterable<Glob> globalExclude;
  final Iterable<Rule> codeRules;
  final Iterable<Metric> classesMetrics;
  final Iterable<Metric> methodsMetrics;
  final Iterable<Glob> metricsExclude;

  const PluginConfig({
    @required this.globalExclude,
    @required this.codeRules,
    @required this.classesMetrics,
    @required this.methodsMetrics,
    @required this.metricsExclude,
  });
}
