@TestOn('vm')
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:code_checker/src/metrics/maximum_nesting_level/nesting_level_visitor.dart';
import 'package:code_checker/src/scope_visitor.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

const examplePath = 'test/resources/maximum_nesting_level_example.dart';

Future<void> main() async {
  final result = await resolveFile(path: p.normalize(p.absolute(examplePath)));

  group('NestingLevelVisitor collect information about nesting levels', () {
    final scopeVisitor = ScopeVisitor();
    result.unit.visitChildren(scopeVisitor);

    test('in simple function', () {
      final declaration = scopeVisitor.functions.first.declaration;

      final nestingLevelVisitor = NestingLevelVisitor(declaration);
      declaration.visitChildren(nestingLevelVisitor);

      expect(
        nestingLevelVisitor.deepestNestingNodesChain.map((node) => node.offset),
        equals([159, 137, 33]),
      );
    });

    test('in constructor', () {
      final declaration = scopeVisitor.functions.toList()[1].declaration;

      final nestingLevelVisitor = NestingLevelVisitor(declaration);
      declaration.visitChildren(nestingLevelVisitor);

      expect(
        nestingLevelVisitor.deepestNestingNodesChain.map((node) => node.offset),
        equals([353, 303]),
      );
    });

    test('in class method', () {
      final declaration = scopeVisitor.functions.last.declaration;

      final nestingLevelVisitor = NestingLevelVisitor(declaration);
      declaration.visitChildren(nestingLevelVisitor);

      expect(
        nestingLevelVisitor.deepestNestingNodesChain.map((node) => node.offset),
        equals([538, 504]),
      );
    });
  });
}
