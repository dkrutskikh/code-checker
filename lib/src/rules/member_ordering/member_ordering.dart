import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:meta/meta.dart';

import '../../models/issue.dart';
import '../../models/severity.dart';
import '../../utils/issue_utils.dart';
import '../../utils/node_utils.dart';
import '../../utils/rule_utils.dart';
import '../rule.dart';
import '../rule_documentation.dart';

// Inspired by ESLint (https://github.com/typescript-eslint/typescript-eslint/blob/master/packages/eslint-plugin/docs/rules/member-ordering.md)

const _documentation = RuleDocumentation(
  name: 'Member Ordering',
  brief: 'Enforces a consistent member declaration order',
);

const _warningMessage = 'should be before';
const _warningAlphabeticalMessage = 'should be alphabetically before';

class MemberOrderingRule extends Rule {
  static const ruleId = 'member-ordering';

  MemberOrderingRule({Map<String, Object> config = const {}})
      : _groupsOrder = _parseOrder(config),
        _alphabetically = (config['order'] as String)?.toLowerCase() == 'alphabetically',
        super(
          id: ruleId,
          documentation: _documentation,
          severity: readSeverity(config, Severity.style),
        );

  final List<_MembersGroup> _groupsOrder;
  final bool _alphabetically;
/*
  @override
  Iterable<Issue> check(ResolvedUnitResult source) {
    final _visitor = _Visitor(_groupsOrder);

    final membersInfo = [
      for (final entry in source.unit.childEntities)
        if (entry is ClassDeclaration) ...entry.accept(_visitor),
    ];

    return [
      ...membersInfo.where((info) => info.memberOrder.isWrong).map(
            (info) => createIssue(
              rule: this,
              location: nodeLocation(
                node: info.classMember,
                source: source,
                withCommentOrMetadata: true,
              ),
              message:
                  '${info.memberOrder.memberGroup.name} $_warningMessage ${info.memberOrder.previousMemberGroup.name}',
            ),
          ),
      if (_alphabetically)
        ...membersInfo
            .where((info) => info.memberOrder.isAlphabeticallyWrong)
            .map(
              (info) => createIssue(
                rule: this,
                location: nodeLocation(
                  node: info.classMember,
                  source: source,
                  withCommentOrMetadata: true,
                ),
                message:
                    '${info.memberOrder.memberNames.currentName} $_warningAlphabeticalMessage ${info.memberOrder.memberNames.previousName}',
              ),
            ),
    ];
  }

  static List<_MembersGroup> _parseOrder(Map<String, Object> config) {
    final order = config.containsKey('order') && config['order'] is Iterable
        ? List<String>.from(config['order'] as Iterable)
        : <String>[];

    return order.isEmpty
        ? _MembersGroup._groupsOrder
        : order
            .map(_MembersGroup.parse)
            .where((group) => group != null)
            .toList();
  }
 */
}

class _Visitor extends RecursiveAstVisitor<List<_MemberInfo>> {
  final List<_MembersGroup> _groupsOrder;
  final _membersInfo = <_MemberInfo>[];

  _Visitor(this._groupsOrder);

  @override
  List<_MemberInfo> visitClassDeclaration(ClassDeclaration node) {
    super.visitClassDeclaration(node);

    _membersInfo.clear();

    for (final member in node.members) {
      if (member is FieldDeclaration) {
        _visitFieldDeclaration(member);
      } else if (member is ConstructorDeclaration) {
        _visitConstructorDeclaration(member);
      } else if (member is MethodDeclaration) {
        _visitMethodDeclaration(member);
      }
    }

    return _membersInfo;
  }

  void _visitFieldDeclaration(FieldDeclaration fieldDeclaration) {
    for (final variable in fieldDeclaration.fields.variables) {
      final membersGroup = Identifier.isPrivateName(variable.name.name)
          ? _MembersGroup.privateFields
          : _MembersGroup.publicFields;

      if (_groupsOrder.contains(membersGroup)) {
        _membersInfo.add(_MemberInfo(
          classMember: fieldDeclaration,
          memberOrder: _getOrder(membersGroup, variable.name.name),
        ));
      }
    }
  }

  void _visitConstructorDeclaration(
    ConstructorDeclaration constructorDeclaration,
  ) {
    if (_groupsOrder.contains(_MembersGroup.constructors)) {
      _membersInfo.add(_MemberInfo(
        classMember: constructorDeclaration,
        memberOrder: _getOrder(
          _MembersGroup.constructors,
          constructorDeclaration.name?.name ?? '',
        ),
      ));
    }
  }

  void _visitMethodDeclaration(MethodDeclaration methodDeclaration) {
    _MembersGroup membersGroup;

    if (methodDeclaration.isGetter) {
      membersGroup = Identifier.isPrivateName(methodDeclaration.name.name)
          ? _MembersGroup.privateGetters
          : _MembersGroup.publicGetters;
    } else if (methodDeclaration.isSetter) {
      membersGroup = Identifier.isPrivateName(methodDeclaration.name.name)
          ? _MembersGroup.privateSetters
          : _MembersGroup.publicSetters;
    } else {
      membersGroup = Identifier.isPrivateName(methodDeclaration.name.name)
          ? _MembersGroup.privateMethods
          : _MembersGroup.publicMethods;
    }

    if (_groupsOrder.contains(membersGroup)) {
      _membersInfo.add(_MemberInfo(
        classMember: methodDeclaration,
        memberOrder: _getOrder(membersGroup, methodDeclaration.name.name),
      ));
    }
  }

  _MemberOrder _getOrder(_MembersGroup memberGroup, String memberName) {
    if (_membersInfo.isNotEmpty) {
      final lastMemberOrder = _membersInfo.last.memberOrder;
      final hasSameGroup = lastMemberOrder.memberGroup == memberGroup;

      final previousMemberGroup = hasSameGroup
          ? lastMemberOrder.previousMemberGroup
          : lastMemberOrder.memberGroup;

      final memberNames = _MemberNames(
        currentName: memberName,
        previousName: lastMemberOrder.memberNames.currentName,
      );

      return _MemberOrder(
        memberNames: memberNames,
        isAlphabeticallyWrong: hasSameGroup &&
            memberNames.currentName.compareTo(memberNames.previousName) != 1,
        memberGroup: memberGroup,
        previousMemberGroup: previousMemberGroup,
        isWrong: (hasSameGroup && lastMemberOrder.isWrong) ||
            _isCurrentGroupBefore(lastMemberOrder.memberGroup, memberGroup),
      );
    }

    return _MemberOrder(
      memberNames: _MemberNames(currentName: memberName),
      isAlphabeticallyWrong: false,
      memberGroup: memberGroup,
      isWrong: false,
    );
  }

  bool _isCurrentGroupBefore(
    _MembersGroup lastMemberGroup,
    _MembersGroup memberGroup,
  ) =>
      _groupsOrder.indexOf(lastMemberGroup) > _groupsOrder.indexOf(memberGroup);
}

class _Type {
  static const constructor = _Type('constructor');
  static const field = _Type('field');
  static const getterSetter = _Type('getset');
  static const method = _Type('method');

  static const values = [field, getterSetter, constructor, method];

  final String _value;

  const _Type(this._value);

  @override
  String toString() => _value;
}

class _Accessibility {
  static const public = _Accessibility('public');
  static const protected = _Accessibility('protected');
  static const private = _Accessibility('private');

  static const values = [public, protected, private];

  final String _value;

  const _Accessibility(this._value);

  @override
  String toString() => _value;
}

class _Modifier {
  static const constant = _Modifier('const');
  static const factory = _Modifier('factory');
  static const static = _Modifier('static');

  static const values = [constant, factory, static];

  final String _value;

  const _Modifier(this._value);

  @override
  String toString() => _value;
}

@immutable
class _MembersGroup {
  final _Accessibility accessibility;
  final Iterable<_Modifier> modifiers;
  final _Type type;

  const _MembersGroup._({
    @required this.accessibility,
    @required this.modifiers,
    @required this.type,
  });

  static _MembersGroup fromString(String name) {
    final accessibility = _Accessibility.values.firstWhere(
      (value) => name.contains(value.toString()),
      orElse: () => null,
    );

    final modifiers = _Modifier.values
        .where((value) => name.contains(value.toString()))
        .toList(growable: false);

    final type = _Type.values.firstWhere(
      (value) => name.contains(value.toString()),
      orElse: () => null,
    );

    return _MembersGroup._(
      accessibility: accessibility,
      modifiers: modifiers,
      type: type,
    );
  }
}

@immutable
class _MemberInfo {
  final ClassMember classMember;
  final _MemberOrder memberOrder;

  const _MemberInfo({
    this.classMember,
    this.memberOrder,
  });
}

@immutable
class _MemberOrder {
  final bool isWrong;
  final bool isAlphabeticallyWrong;
  final _MemberNames memberNames;
  final _MembersGroup memberGroup;
  final _MembersGroup previousMemberGroup;

  const _MemberOrder({
    this.isWrong,
    this.isAlphabeticallyWrong,
    this.memberNames,
    this.memberGroup,
    this.previousMemberGroup,
  });
}

@immutable
class _MemberNames {
  final String currentName;
  final String previousName;

  const _MemberNames({
    this.currentName,
    this.previousName,
  });
}

/*
export type MessageIds = 'incorrectGroupOrder' | 'incorrectOrder';

interface SortedOrderConfig {
  memberTypes?: string[] | 'never';
  order: 'alphabetically' | 'as-written';
}

type OrderConfig = string[] | SortedOrderConfig | 'never';
type Member = TSESTree.ClassElement | TSESTree.TypeElement;

export type Options = [
  {
    default?: OrderConfig;
    classes?: OrderConfig;
    classExpressions?: OrderConfig;
    interfaces?: OrderConfig;
    typeLiterals?: OrderConfig;
  },
];

const neverConfig: JSONSchema.JSONSchema4 = {
  type: 'string',
  enum: ['never'],
};

const arrayConfig = (memberTypes: string[]): JSONSchema.JSONSchema4 => ({
  type: 'array',
  items: {
    enum: memberTypes,
  },
});

const objectConfig = (memberTypes: string[]): JSONSchema.JSONSchema4 => ({
  type: 'object',
  properties: {
    memberTypes: {
      oneOf: [arrayConfig(memberTypes), neverConfig],
    },
    order: {
      type: 'string',
      enum: ['alphabetically', 'as-written'],
    },
  },
  additionalProperties: false,
});

export const defaultOrder = [
  // Index signature
  'signature',

  // Fields
  'public-static-field',
  'protected-static-field',
  'private-static-field',

  'public-decorated-field',
  'protected-decorated-field',
  'private-decorated-field',

  'public-instance-field',
  'protected-instance-field',
  'private-instance-field',

  'public-abstract-field',
  'protected-abstract-field',
  'private-abstract-field',

  'public-field',
  'protected-field',
  'private-field',

  'static-field',
  'instance-field',
  'abstract-field',

  'decorated-field',

  'field',

  // Constructors
  'public-constructor',
  'protected-constructor',
  'private-constructor',

  'constructor',

  // Methods
  'public-static-method',
  'protected-static-method',
  'private-static-method',

  'public-decorated-method',
  'protected-decorated-method',
  'private-decorated-method',

  'public-instance-method',
  'protected-instance-method',
  'private-instance-method',

  'public-abstract-method',
  'protected-abstract-method',
  'private-abstract-method',

  'public-method',
  'protected-method',
  'private-method',

  'static-method',
  'instance-method',
  'abstract-method',

  'decorated-method',

  'method',
];

const allMemberTypes = ['signature', 'field', 'method', 'constructor'].reduce<
  string[]
>((all, type) => {
  all.push(type);

  ['public', 'protected', 'private'].forEach(accessibility => {
    if (type !== 'signature') {
      all.push(`${accessibility}-${type}`); // e.g. `public-field`
    }

    // Only class instance fields and methods can have decorators attached to them
    if (type === 'field' || type === 'method') {
      const decoratedMemberType = `${accessibility}-decorated-${type}`;
      const decoratedMemberTypeNoAccessibility = `decorated-${type}`;
      if (!all.includes(decoratedMemberType)) {
        all.push(decoratedMemberType);
      }
      if (!all.includes(decoratedMemberTypeNoAccessibility)) {
        all.push(decoratedMemberTypeNoAccessibility);
      }
    }

    if (type !== 'constructor' && type !== 'signature') {
      // There is no `static-constructor` or `instance-constructor` or `abstract-constructor`
      ['static', 'instance', 'abstract'].forEach(scope => {
        if (!all.includes(`${scope}-${type}`)) {
          all.push(`${scope}-${type}`);
        }

        all.push(`${accessibility}-${scope}-${type}`);
      });
    }
  });

  return all;
}, []);

const functionExpressions = [
  AST_NODE_TYPES.FunctionExpression,
  AST_NODE_TYPES.ArrowFunctionExpression,
];

/**
 * Gets the node type.
 *
 * @param node the node to be evaluated.
 */
function getNodeType(node: Member): string | null {
  // TODO: add missing TSCallSignatureDeclaration
  switch (node.type) {
    case AST_NODE_TYPES.TSAbstractMethodDefinition:
    case AST_NODE_TYPES.MethodDefinition:
      return node.kind;
    case AST_NODE_TYPES.TSMethodSignature:
      return 'method';
    case AST_NODE_TYPES.TSConstructSignatureDeclaration:
      return 'constructor';
    case AST_NODE_TYPES.TSAbstractClassProperty:
    case AST_NODE_TYPES.ClassProperty:
      return node.value && functionExpressions.includes(node.value.type)
        ? 'method'
        : 'field';
    case AST_NODE_TYPES.TSPropertySignature:
      return 'field';
    case AST_NODE_TYPES.TSIndexSignature:
      return 'signature';
    default:
      return null;
  }
}

/**
 * Gets the member name based on the member type.
 *
 * @param node the node to be evaluated.
 * @param sourceCode
 */
function getMemberName(
  node: Member,
  sourceCode: TSESLint.SourceCode,
): string | null {
  switch (node.type) {
    case AST_NODE_TYPES.TSPropertySignature:
    case AST_NODE_TYPES.TSMethodSignature:
    case AST_NODE_TYPES.TSAbstractClassProperty:
    case AST_NODE_TYPES.ClassProperty:
      return util.getNameFromMember(node, sourceCode);
    case AST_NODE_TYPES.TSAbstractMethodDefinition:
    case AST_NODE_TYPES.MethodDefinition:
      return node.kind === 'constructor'
        ? 'constructor'
        : util.getNameFromMember(node, sourceCode);
    case AST_NODE_TYPES.TSConstructSignatureDeclaration:
      return 'new';
    case AST_NODE_TYPES.TSIndexSignature:
      return util.getNameFromIndexSignature(node);
    default:
      return null;
  }
}

/**
 * Gets the calculated rank using the provided method definition.
 * The algorithm is as follows:
 * - Get the rank based on the accessibility-scope-type name, e.g. public-instance-field
 * - If there is no order for accessibility-scope-type, then strip out the accessibility.
 * - If there is no order for scope-type, then strip out the scope.
 * - If there is no order for type, then return -1
 * @param memberGroups the valid names to be validated.
 * @param orderConfig the current order to be validated.
 *
 * @return Index of the matching member type in the order configuration.
 */
function getRankOrder(memberGroups: string[], orderConfig: string[]): number {
  let rank = -1;
  const stack = memberGroups.slice(); // Get a copy of the member groups

  while (stack.length > 0 && rank === -1) {
    rank = orderConfig.indexOf(stack.shift()!);
  }

  return rank;
}

/**
 * Gets the rank of the node given the order.
 * @param node the node to be evaluated.
 * @param orderConfig the current order to be validated.
 * @param supportsModifiers a flag indicating whether the type supports modifiers (scope or accessibility) or not.
 */
function getRank(
  node: Member,
  orderConfig: string[],
  supportsModifiers: boolean,
): number {
  const type = getNodeType(node);

  if (type === null) {
    // shouldn't happen but just in case, put it on the end
    return orderConfig.length - 1;
  }

  const abstract =
    node.type === AST_NODE_TYPES.TSAbstractClassProperty ||
    node.type === AST_NODE_TYPES.TSAbstractMethodDefinition;

  const scope =
    'static' in node && node.static
      ? 'static'
      : abstract
      ? 'abstract'
      : 'instance';
  const accessibility =
    'accessibility' in node && node.accessibility
      ? node.accessibility
      : 'public';

  // Collect all existing member groups (e.g. 'public-instance-field', 'instance-field', 'public-field', 'constructor' etc.)
  const memberGroups = [];

  if (supportsModifiers) {
    const decorated = 'decorators' in node && node.decorators!.length > 0;
    if (decorated && (type === 'field' || type === 'method')) {
      memberGroups.push(`${accessibility}-decorated-${type}`);
      memberGroups.push(`decorated-${type}`);
    }

    if (type !== 'constructor') {
      // Constructors have no scope
      memberGroups.push(`${accessibility}-${scope}-${type}`);
      memberGroups.push(`${scope}-${type}`);
    }

    memberGroups.push(`${accessibility}-${type}`);
  }

  memberGroups.push(type);

  return getRankOrder(memberGroups, orderConfig);
}

/**
 * Gets the lowest possible rank higher than target.
 * e.g. given the following order:
 *   ...
 *   public-static-method
 *   protected-static-method
 *   private-static-method
 *   public-instance-method
 *   protected-instance-method
 *   private-instance-method
 *   ...
 * and considering that a public-instance-method has already been declared, so ranks contains
 * public-instance-method, then the lowest possible rank for public-static-method is
 * public-instance-method.
 * @param ranks the existing ranks in the object.
 * @param target the target rank.
 * @param order the current order to be validated.
 * @returns the name of the lowest possible rank without dashes (-).
 */
function getLowestRank(
  ranks: number[],
  target: number,
  order: string[],
): string {
  let lowest = ranks[ranks.length - 1];

  ranks.forEach(rank => {
    if (rank > target) {
      lowest = Math.min(lowest, rank);
    }
  });

  return order[lowest].replace(/-/g, ' ');
}

export default util.createRule<Options, MessageIds>({
  name: 'member-ordering',
  meta: {
    type: 'suggestion',
    docs: {
      description: 'Require a consistent member declaration order',
      category: 'Stylistic Issues',
      recommended: false,
    },
    messages: {
      incorrectOrder:
        'Member "{{member}}" should be declared before member "{{beforeMember}}".',
      incorrectGroupOrder:
        'Member {{name}} should be declared before all {{rank}} definitions.',
    },
    schema: [
      {
        type: 'object',
        properties: {
          default: {
            oneOf: [
              neverConfig,
              arrayConfig(allMemberTypes),
              objectConfig(allMemberTypes),
            ],
          },
          classes: {
            oneOf: [
              neverConfig,
              arrayConfig(allMemberTypes),
              objectConfig(allMemberTypes),
            ],
          },
          classExpressions: {
            oneOf: [
              neverConfig,
              arrayConfig(allMemberTypes),
              objectConfig(allMemberTypes),
            ],
          },
          interfaces: {
            oneOf: [
              neverConfig,
              arrayConfig(['signature', 'field', 'method', 'constructor']),
              objectConfig(['signature', 'field', 'method', 'constructor']),
            ],
          },
          typeLiterals: {
            oneOf: [
              neverConfig,
              arrayConfig(['signature', 'field', 'method', 'constructor']),
              objectConfig(['signature', 'field', 'method', 'constructor']),
            ],
          },
        },
        additionalProperties: false,
      },
    ],
  },
  defaultOptions: [
    {
      default: defaultOrder,
    },
  ],
  create(context, [options]) {
    /**
     * Checks if the member groups are correctly sorted.
     *
     * @param members Members to be validated.
     * @param groupOrder Group order to be validated.
     * @param supportsModifiers A flag indicating whether the type supports modifiers (scope or accessibility) or not.
     *
     * @return Array of member groups or null if one of the groups is not correctly sorted.
     */
    function checkGroupSort(
      members: Member[],
      groupOrder: string[],
      supportsModifiers: boolean,
    ): Array<Member[]> | null {
      const previousRanks: number[] = [];
      const memberGroups: Array<Member[]> = [];
      let isCorrectlySorted = true;

      // Find first member which isn't correctly sorted
      members.forEach(member => {
        const rank = getRank(member, groupOrder, supportsModifiers);
        const name = getMemberName(member, context.getSourceCode());
        const rankLastMember = previousRanks[previousRanks.length - 1];

        if (rank === -1) {
          return;
        }

        // Works for 1st item because x < undefined === false for any x (typeof string)
        if (rank < rankLastMember) {
          context.report({
            node: member,
            messageId: 'incorrectGroupOrder',
            data: {
              name,
              rank: getLowestRank(previousRanks, rank, groupOrder),
            },
          });

          isCorrectlySorted = false;
        } else if (rank === rankLastMember) {
          // Same member group --> Push to existing member group array
          memberGroups[memberGroups.length - 1].push(member);
        } else {
          // New member group --> Create new member group array
          previousRanks.push(rank);
          memberGroups.push([member]);
        }
      });

      return isCorrectlySorted ? memberGroups : null;
    }

    /**
     * Checks if the members are alphabetically sorted.
     *
     * @param members Members to be validated.
     *
     * @return True if all members are correctly sorted.
     */
    function checkAlphaSort(members: Member[]): boolean {
      let previousName = '';
      let isCorrectlySorted = true;

      // Find first member which isn't correctly sorted
      members.forEach(member => {
        const name = getMemberName(member, context.getSourceCode());

        // Note: Not all members have names
        if (name) {
          if (name < previousName) {
            context.report({
              node: member,
              messageId: 'incorrectOrder',
              data: {
                member: name,
                beforeMember: previousName,
              },
            });

            isCorrectlySorted = false;
          }

          previousName = name;
        }
      });

      return isCorrectlySorted;
    }

    /**
     * Validates if all members are correctly sorted.
     *
     * @param members Members to be validated.
     * @param orderConfig Order config to be validated.
     * @param supportsModifiers A flag indicating whether the type supports modifiers (scope or accessibility) or not.
     */
    function validateMembersOrder(
      members: Member[],
      orderConfig: OrderConfig,
      supportsModifiers: boolean,
    ): void {
      if (orderConfig === 'never') {
        return;
      }

      // Standardize config
      let order = null;
      let memberTypes;

      if (Array.isArray(orderConfig)) {
        memberTypes = orderConfig;
      } else {
        order = orderConfig.order;
        memberTypes = orderConfig.memberTypes;
      }

      // Check order
      if (Array.isArray(memberTypes)) {
        const grouped = checkGroupSort(members, memberTypes, supportsModifiers);

        if (grouped === null) {
          return;
        }

        if (order === 'alphabetically') {
          grouped.some(groupMember => !checkAlphaSort(groupMember));
        }
      } else if (order === 'alphabetically') {
        checkAlphaSort(members);
      }
    }

    return {
      ClassDeclaration(node): void {
        validateMembersOrder(
          node.body.body,
          options.classes ?? options.default!,
          true,
        );
      },
      ClassExpression(node): void {
        validateMembersOrder(
          node.body.body,
          options.classExpressions ?? options.default!,
          true,
        );
      },
      TSInterfaceDeclaration(node): void {
        validateMembersOrder(
          node.body.body,
          options.interfaces ?? options.default!,
          false,
        );
      },
      TSTypeLiteral(node): void {
        validateMembersOrder(
          node.members,
          options.typeLiterals ?? options.default!,
          false,
        );
      },
    };
  },
});
 */
