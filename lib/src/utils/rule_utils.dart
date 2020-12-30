import '../models/severity.dart';

/// Returns a [Severity] from [Map] based [config] otherwise [defaultValue]
Severity readSeverity(Map<String, Object> config, Severity defaultValue) =>
    Severity.fromString(config['severity'] as String) ?? defaultValue;
