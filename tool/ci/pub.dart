import 'dart:io';

void publishToPub() {
  Directory('~/.pub-cache').createSync(recursive: true);
  File('~/.pub-cache/credentials.json').writeAsStringSync(
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
