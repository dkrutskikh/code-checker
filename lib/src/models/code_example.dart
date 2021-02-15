import 'package:meta/meta.dart';

@immutable
class CodeExample {
  final String examplePath;

  final int startLine;

  const CodeExample({
    @required this.examplePath,
    @required this.startLine,
  });
}
