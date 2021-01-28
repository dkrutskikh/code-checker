import 'dart:io';
import 'dart:isolate';

import 'package:meta/meta.dart';
import 'package:yaml/yaml.dart';

import '../utils/analysis_options_utils.dart';
import '../utils/yaml_utils.dart';

const String analysisOptionsFileName = 'analysis_options.yaml';

/// Class representing dart analysis options
@immutable
class AnalysisOptions {
  final Map<String, Object> options;

  const AnalysisOptions(this.options);

  Iterable<String> readIterableOfString(Iterable<String> pathSegments) {
    Object data = options;

    for (final key in pathSegments) {
      if (data is Map<String, Object> && data.containsKey(key)) {
        data = (data as Map<String, Object>)[key];
      } else {
        return [];
      }
    }

    return isIterableOfStrings(data) ? (data as Iterable).cast<String>() : [];
  }

  Map<String, Object> readMap(Iterable<String> pathSegments) {
    Object data = options;

    for (final key in pathSegments) {
      if (data is Map<String, Object> && data.containsKey(key)) {
        data = (data as Map<String, Object>)[key];
      } else {
        return {};
      }
    }

    return data is Map<String, Object> ? data : {};
  }
}

Future<AnalysisOptions> analysisOptionsFromFile(File options) async =>
    options != null && options.existsSync()
        ? AnalysisOptions(await _loadConfigFromYamlFile(options))
        : const AnalysisOptions({});

Future<Map<String, Object>> _loadConfigFromYamlFile(File options) async {
  try {
    final node = loadYamlNode(options?.readAsStringSync() ?? '');

    var optionsNode =
        node is YamlMap ? yamlMapToDartMap(node) : <String, Object>{};

    final includeNode = optionsNode['include'];
    if (includeNode is String) {
      final resolvedUri =
          await Isolate.resolvePackageUri(Uri.parse(includeNode));
      if (resolvedUri != null) {
        final resolvedYamlMap =
            await _loadConfigFromYamlFile(File.fromUri(resolvedUri));
        optionsNode =
            mergeMaps(defaults: resolvedYamlMap, overrides: optionsNode);
      }
    }

    return optionsNode;
  } on YamlException catch (e) {
    throw FormatException(e.message, e.span);
  }
}
