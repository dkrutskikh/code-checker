import 'dart:io';

void publishToPub() {
  final pubCachePath = getPubCachePath();
  Directory(pubCachePath).createSync(recursive: true);
  File('$pubCachePath/credentials.json').writeAsStringSync(
    Platform.environment['PUB_CREDENTIALS'],
    mode: FileMode.writeOnly,
    flush: true,
  );

  final pubCommands = [
    ['pub', 'publish', '--force'],
  ];

  for (final command in pubCommands) {
    final result = Process.runSync('dart', command);
    stdout.write(result.stdout);
    stderr.write(result.stderr);
    if (result.exitCode != 0) {
      exit(exitCode);
    }
  }
}

String getPubCachePath() {
  if (Platform.environment.containsKey('PUB_CACHE')) {
    return Platform.environment['PUB_CACHE'];
  } else if (Platform.operatingSystem == 'windows') {
    return '${Platform.environment['APPDATA']}/Pub/Cache';
  } else {
    return '${Platform.environment['HOME']}/.pub-cache';
  }
}
