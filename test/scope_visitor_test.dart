@TestOn('vm')
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:code_checker/src/models/class_type.dart';
import 'package:code_checker/src/models/function_type.dart';
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

      final classDeclaration = visitor.classes.single;
      expect(
        classDeclaration.declaration,
        const TypeMatcher<ClassDeclaration>(),
      );
      expect(classDeclaration.type, equals(ClassType.generic));
      expect(classDeclaration.name, equals('Doer'));

      final function = visitor.functions.single;
      expect(function.type, equals(FunctionType.method));
      expect(function.name, equals('doSomething'));
      expect(function.fullName, equals('Doer.doSomething'));
    });

    test('class with factory constructors', () async {
      (await resolveFile(
        path: p.normalize(p
            .absolute('./test/resources/class_with_factory_constructors.dart')),
      ))
          .unit
          .visitChildren(visitor);

      final classDeclaration = visitor.classes.single;
      expect(
        classDeclaration.declaration,
        const TypeMatcher<ClassDeclaration>(),
      );
      expect(classDeclaration.type, equals(ClassType.generic));
      expect(classDeclaration.name, equals('Logger'));

      final functions = visitor.functions.toList(growable: false);
      expect(functions.length, equals(4));

      final factoryConstructor = functions.first;
      expect(factoryConstructor.type, equals(FunctionType.constructor));
      expect(factoryConstructor.name, equals('Logger'));
      expect(factoryConstructor.fullName, equals('Logger.Logger'));

      final fromJson = functions[1];
      expect(fromJson.type, equals(FunctionType.constructor));
      expect(fromJson.name, equals('fromJson'));
      expect(fromJson.fullName, equals('Logger.fromJson'));

      final constructor = functions[2];
      expect(constructor.type, equals(FunctionType.constructor));
      expect(constructor.name, equals('_internal'));
      expect(constructor.fullName, equals('Logger._internal'));

      expect(functions.last.type, equals(FunctionType.method));
      expect(functions.last.name, equals('log'));
      expect(functions.last.fullName, equals('Logger.log'));
    });

    test('extension with method', () async {
      (await resolveFile(
        path: p.normalize(p.absolute('./test/resources/extension.dart')),
      ))
          .unit
          .visitChildren(visitor);

      final classDeclaration = visitor.classes.single;
      expect(
        classDeclaration.declaration,
        const TypeMatcher<ExtensionDeclaration>(),
      );
      expect(classDeclaration.type, equals(ClassType.extension));
      expect(classDeclaration.name, equals('NumberParsing'));

      final function = visitor.functions.single;
      expect(function.type, equals(FunctionType.method));
      expect(function.name, equals('parseInt'));
      expect(function.fullName, equals('NumberParsing.parseInt'));
    });

    test('mixin', () async {
      (await resolveFile(
        path: p.normalize(p.absolute('./test/resources/mixin.dart')),
      ))
          .unit
          .visitChildren(visitor);

      final classDeclaration = visitor.classes.single;
      expect(
        classDeclaration.declaration,
        const TypeMatcher<MixinDeclaration>(),
      );
      expect(classDeclaration.type, equals(ClassType.mixin));
      expect(classDeclaration.name, equals('Musical'));

      final function = visitor.functions.single;
      expect(function.type, equals(FunctionType.method));
      expect(function.name, equals('entertainMe'));
      expect(function.fullName, equals('Musical.entertainMe'));
    });

    test('functions', () async {
      (await resolveFile(
        path: p.normalize(p.absolute('./test/resources/functions.dart')),
      ))
          .unit
          .visitChildren(visitor);

      expect(visitor.classes, isEmpty);

      expect(visitor.functions.length, equals(2));

      expect(visitor.functions.first.type, equals(FunctionType.function));
      expect(visitor.functions.first.name, equals('printInteger'));
      expect(visitor.functions.first.fullName, equals('printInteger'));

      expect(visitor.functions.last.type, equals(FunctionType.function));
      expect(visitor.functions.last.name, equals('main'));
      expect(visitor.functions.last.fullName, equals('main'));
    });

    test('two classes', () async {
      (await resolveFile(
        path: p.normalize(
          p.absolute('./test/resources/weight_of_class_example.dart'),
        ),
      ))
          .unit
          .visitChildren(visitor);

      expect(visitor.classes.length, equals(2));

      expect(
        visitor.classes.first.declaration,
        const TypeMatcher<ClassDeclaration>(),
      );
      expect(visitor.classes.first.type, equals(ClassType.generic));
      expect(visitor.classes.first.name, equals('SimpleClass'));

      expect(
        visitor.classes.last.declaration,
        const TypeMatcher<ClassDeclaration>(),
      );
      expect(visitor.classes.last.type, equals(ClassType.generic));
      expect(visitor.classes.last.name, equals('Spacecraft'));

      final functions = visitor.functions.toList(growable: false);
      expect(functions.length, equals(6));

      final constructor1 = functions.first;
      expect(constructor1.type, equals(FunctionType.constructor));
      expect(constructor1.name, equals('SimpleClass'));
      expect(constructor1.fullName, equals('SimpleClass.SimpleClass'));

      final lettersCount = functions[1];
      expect(lettersCount.type, equals(FunctionType.getter));
      expect(lettersCount.name, equals('lettersCount'));
      expect(lettersCount.fullName, equals('SimpleClass.lettersCount'));

      final constructor2 = functions[2];
      expect(constructor2.type, equals(FunctionType.constructor));
      expect(constructor2.name, equals('Spacecraft'));
      expect(constructor2.fullName, equals('Spacecraft.Spacecraft'));

      final unLaunched = functions[3];
      expect(unLaunched.type, equals(FunctionType.constructor));
      expect(unLaunched.name, equals('unlaunched'));
      expect(unLaunched.fullName, equals('Spacecraft.unlaunched'));

      final launchYear = functions[4];
      expect(launchYear.type, equals(FunctionType.getter));
      expect(launchYear.name, equals('launchYear'));
      expect(launchYear.fullName, equals('Spacecraft.launchYear'));

      final describe = functions[5];
      expect(describe.type, equals(FunctionType.method));
      expect(describe.name, equals('describe'));
      expect(describe.fullName, equals('Spacecraft.describe'));
    });
  });
}
