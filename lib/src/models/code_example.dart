import 'package:meta/meta.dart';

@immutable
class CodeExample {
  final String examplePath;

  final int startLine;
  final int endLine;

  const CodeExample({
    @required this.examplePath,
    @required this.startLine,
    @required this.endLine,
  });
}
