@TestOn('vm')
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:code_checker/checker.dart';
import 'package:code_checker/src/scope_visitor.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('ScopeVisitor collects scope from file with', () {
    ScopeVisitor visitor;

    setUp(() {
      visitor = ScopeVisitor();
    });

    test('abstract class', () async {
      (await resolveFile(
        path: p.normalize(p.absolute('./test/resources/abstract_class.dart')),
      ))
          .unit
          .visitChildren(visitor);

      final component = visitor.components.single;
      expect(component.declaration, const TypeMatcher<ClassDeclaration>());
      expect(component.humanReadableName, equals('Doer'));

      final function = visitor.functions.single;
      expect(function.type, equals(FunctionType.method));
      expect(function.declaration, const TypeMatcher<MethodDeclaration>());
      expect(
        (function.declaration as MethodDeclaration).name.name,
        equals('doSomething'),
      );
      expect(
        function.enclosingDeclaration.declaration,
        const TypeMatcher<ClassDeclaration>(),
      );
      expect(
        (function.enclosingDeclaration.declaration as ClassDeclaration)
            .name
            .name,
        equals('Doer'),
      );
    });

    test('class with factory constructors', () async {
      (await resolveFile(
        path: p.normalize(p
            .absolute('./test/resources/class_with_factory_constructors.dart')),
      ))
          .unit
          .visitChildren(visitor);

      final component = visitor.components.single;
      expect(component.declaration, const TypeMatcher<ClassDeclaration>());
      expect(component.humanReadableName, equals('Logger'));

      final functions = visitor.functions.toList();
      expect(functions.length, equals(4));

      final factoryConstructor = functions.first;
      expect(factoryConstructor.type, equals(FunctionType.constructor));
      expect(
        factoryConstructor.declaration,
        const TypeMatcher<ConstructorDeclaration>(),
      );
      expect(
        (factoryConstructor.declaration as ConstructorDeclaration).name,
        isNull,
      );
      expect(
        factoryConstructor.enclosingDeclaration.declaration,
        const TypeMatcher<ClassDeclaration>(),
      );
      expect(
        (factoryConstructor.enclosingDeclaration.declaration
                as ClassDeclaration)
            .name
            .name,
        equals('Logger'),
      );

      final fromJson = functions[1];
      expect(fromJson.type, equals(FunctionType.constructor));
      expect(
        fromJson.declaration,
        const TypeMatcher<ConstructorDeclaration>(),
      );
      expect(
        (fromJson.declaration as ConstructorDeclaration).name.name,
        'fromJson',
      );
      expect(
        fromJson.enclosingDeclaration.declaration,
        const TypeMatcher<ClassDeclaration>(),
      );
      expect(
        (fromJson.enclosingDeclaration.declaration as ClassDeclaration)
            .name
            .name,
        equals('Logger'),
      );

      final constructor = functions[2];
      expect(constructor.type, equals(FunctionType.constructor));
      expect(
        constructor.declaration,
        const TypeMatcher<ConstructorDeclaration>(),
      );
      expect(
        (constructor.declaration as ConstructorDeclaration).name.name,
        '_internal',
      );
      expect(
        constructor.enclosingDeclaration.declaration,
        const TypeMatcher<ClassDeclaration>(),
      );
      expect(
        (constructor.enclosingDeclaration.declaration as ClassDeclaration)
            .name
            .name,
        equals('Logger'),
      );

      expect(functions.last.type, equals(FunctionType.method));
      expect(
        functions.last.declaration,
        const TypeMatcher<MethodDeclaration>(),
      );
      expect(
        (functions.last.declaration as MethodDeclaration).name.name,
        equals('log'),
      );
      expect(
        functions.last.enclosingDeclaration.declaration,
        const TypeMatcher<ClassDeclaration>(),
      );
      expect(
        (functions.last.enclosingDeclaration.declaration as ClassDeclaration)
            .name
            .name,
        equals('Logger'),
      );
    });

    test('extension with method', () async {
      (await resolveFile(
        path: p.normalize(p.absolute('./test/resources/extension.dart')),
      ))
          .unit
          .visitChildren(visitor);

      final component = visitor.components.single;
      expect(component.declaration, const TypeMatcher<ExtensionDeclaration>());
      expect(component.humanReadableName, equals('NumberParsing'));

      final function = visitor.functions.single;
      expect(function.type, equals(FunctionType.method));
      expect(function.declaration, const TypeMatcher<MethodDeclaration>());
      expect(
        (function.declaration as MethodDeclaration).name.name,
        equals('parseInt'),
      );
      expect(
        function.enclosingDeclaration.declaration,
        const TypeMatcher<ExtensionDeclaration>(),
      );
      expect(
        (function.enclosingDeclaration.declaration as ExtensionDeclaration)
            .name
            .name,
        equals('NumberParsing'),
      );
    });

    test('mixin', () async {
      (await resolveFile(
        path: p.normalize(p.absolute('./test/resources/mixin.dart')),
      ))
          .unit
          .visitChildren(visitor);

      final component = visitor.components.single;
      expect(component.declaration, const TypeMatcher<MixinDeclaration>());
      expect(component.humanReadableName, equals('Musical'));

      final function = visitor.functions.single;
      expect(function.type, equals(FunctionType.method));
      expect(function.declaration, const TypeMatcher<MethodDeclaration>());
      expect(
        (function.declaration as MethodDeclaration).name.name,
        equals('entertainMe'),
      );
      expect(
        function.enclosingDeclaration.declaration,
        const TypeMatcher<MixinDeclaration>(),
      );
      expect(
        (function.enclosingDeclaration.declaration as MixinDeclaration)
            .name
            .name,
        equals('Musical'),
      );
    });

    test('functions', () async {
      (await resolveFile(
        path: p.normalize(p.absolute('./test/resources/functions.dart')),
      ))
          .unit
          .visitChildren(visitor);

      expect(visitor.components, isEmpty);

      expect(visitor.functions.length, equals(2));

      final first = visitor.functions.first;
      expect(first.type, equals(FunctionType.function));
      expect(first.declaration, const TypeMatcher<FunctionDeclaration>());
      expect(
        (first.declaration as FunctionDeclaration).name.name,
        equals('printInteger'),
      );
      expect(first.enclosingDeclaration, isNull);

      final last = visitor.functions.last;
      expect(last.type, equals(FunctionType.function));
      expect(last.declaration, const TypeMatcher<FunctionDeclaration>());
      expect(
        (last.declaration as FunctionDeclaration).name.name,
        equals('main'),
      );
      expect(last.enclosingDeclaration, isNull);
    });
  });
}
