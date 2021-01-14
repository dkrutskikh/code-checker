import 'metrics/metric.dart';
import 'metrics/number_of_methods_metric.dart';
import 'metrics/weight_of_class_metric.dart';

final _implementedMetrics = <String, Metric Function(Map<String, Object>)>{
  NumberOfMethodsMetric.metricId: (config) =>
      NumberOfMethodsMetric(config: config),
  WeightOfClassMetric.metricId: (config) => WeightOfClassMetric(config: config),
};

Iterable<Metric> get allMetrics =>
    _implementedMetrics.keys.map((id) => _implementedMetrics[id]({}));

Iterable<Metric> getMetricsById(Map<String, Object> metricsConfig) =>
    _implementedMetrics.keys
        .where((id) => metricsConfig.keys.contains(id))
        .map((id) => _implementedMetrics[id](metricsConfig));
