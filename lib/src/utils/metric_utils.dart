/// Returns a threshold from [Map] based [config] for metrics with [metricId] otherwise [defaultValue]
T readThreshold<T extends num>(
  Map<String, Object> config,
  String metricId,
  T defaultValue,
) {
  final configValue = config[metricId] as String;

  if (configValue != null && T == int) {
    return int.tryParse(configValue) as T ?? defaultValue;
  } else if (configValue != null && T == double) {
    return double.tryParse(configValue) as T ?? defaultValue;
  }

  return defaultValue;
}
