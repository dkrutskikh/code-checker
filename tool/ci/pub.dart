import 'dart:io';

void publishToPub(String version) {
  Directory('~/.pub-cache').create(recursive: true);
  File('~/.pub-cache/credentials.json')
      .writeAsStringSync(Platform.environment['PUB_CREDENTIALS'], flush: true);

  final pubCommands = [
    ['pub', '--force'],
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
