import 'dart:convert';
import 'dart:io';

enum ChangesImportance {
  unknown,
  patch,
  minor,
  major,
}

Iterable<String> readChangelog() {
  final changelog = File('CHANGELOG.md');
  if (!changelog.existsSync()) {
    return [];
  }

  return LineSplitter.split(changelog.readAsStringSync());
}

void saveChangelog(Iterable<String> content) {
  File('CHANGELOG.md').writeAsStringSync('${content.join('\n')}\n');
}

Iterable<String> readPubspec() {
  final pubspec = File('pubspec.yaml');
  if (!pubspec.existsSync()) {
    return [];
  }

  return LineSplitter.split(pubspec.readAsStringSync());
}

void savePubspec(Iterable<String> content) {
  File('pubspec.yaml').writeAsStringSync('${content.join('\n')}\n');
}

String bumpPackageVersion(String version) {
  const devPattern = '-dev.';

  final preReleasePattern = RegExp('$devPattern([0-9]+)');
  final matches = preReleasePattern.allMatches(version);

  if (matches.isEmpty) {
    return '$version-dev.1';
  }

  final currentDevVersion =
      int.tryParse(matches.first.group(0).substring(devPattern.length)) ?? 0;

  final lastStableVersion = version.substring(0, matches.first.start);

  return '$lastStableVersion$devPattern${currentDevVersion + 1}';
}

int getDevChangesCount(Iterable<String> changelog) {
  final indices = getReleaseLineIndices(changelog).toList();

  return indices.isNotEmpty
      ? changelog
          .toList()
          .sublist(indices[0] + 1, indices[1])
          .where((line) => line.trim().startsWith('* '))
          .length
      : 0;
}

ChangesImportance getDevChangesImportance(Iterable<String> changelog) {
  const _importanceMap = {
    '## major': ChangesImportance.major,
    '## minor': ChangesImportance.minor,
    '## patch': ChangesImportance.patch,
  };

  if (changelog.length < 3) {
    return ChangesImportance.unknown;
  }

  final potentialSeverityLine = (changelog.iterator
        ..moveNext()
        ..moveNext()
        ..moveNext())
      .current
      .trim()
      .toLowerCase();

  return _importanceMap.containsKey(potentialSeverityLine)
      ? _importanceMap[potentialSeverityLine]
      : ChangesImportance.unknown;
}

String getPackageVersion(Iterable<String> pubspec) {
  const versionPattern = 'version:';

  return pubspec
      .firstWhere(
        (line) => line.trim().startsWith(versionPattern),
        orElse: () => '$versionPattern 0.0.0',
      )
      .substring(versionPattern.length + 1);
}

Iterable<int> getReleaseLineIndices(Iterable<String> content) {
  var lineIndex = 0;

  return content.expand((line) {
    lineIndex++;

    return line.startsWith('## ') ? [lineIndex - 1] : [];
  });
}

Iterable<String> patchPubspec(
  Iterable<String> originalContent,
  String newVersion,
) {
  const versionPattern = 'version:';

  final patchedContent = originalContent.map((line) {
    if (line.startsWith(versionPattern)) {
      return '$versionPattern $newVersion';
    }

    return line;
  });

  return patchedContent;
}

Iterable<String> patchChangelog(
  Iterable<String> originalContent,
  String newVersion,
  ChangesImportance importance,
  DateTime changesDate,
) {
  const _importanceMap = {
    ChangesImportance.major: '(MAJOR)',
    ChangesImportance.minor: '(MINOR)',
    ChangesImportance.patch: '(PATCH)',
  };

  final content = originalContent.toList();
  final releaseLineIndexes = getReleaseLineIndices(content).toList();

  final patchedContent = [
    ...content.sublist(0, 2),
    '## $newVersion - ${changesDate.year}-${changesDate.month.toString().padLeft(2, '0')}-${changesDate.day.toString().padLeft(2, '0')}',
    ...content
        .sublist(releaseLineIndexes[0] + 1, releaseLineIndexes[1])
        .map((line) {
      final trimmedLine = line.trim();

      if (trimmedLine.startsWith('* ')) {
        return '$trimmedLine ${_importanceMap[importance]}';
      }

      return trimmedLine;
    }),
    ...content.sublist(releaseLineIndexes[1]),
  ];

  return patchedContent;
}

void printErrorMessage(String verbose) {
  [
    '\u2757 Invalid changelog format. $verbose',
  ].forEach(stderr.writeln);

  [
    'Changelog should look like:',
    '----------------------------',
    '# Changelog',
    '',
    '## MAJOR | MINOR | PATCH',
    '',
    '* change 1',
    '* change 2',
    '* ...',
    '',
    '## ....',
    '',
    '----------------------------',
  ].forEach(stdout.writeln);

  exit(1);
}
