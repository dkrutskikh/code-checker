/// Enum class for type of a type of entity
class EntityType {
  static const EntityType classEntity = EntityType._('class');
  static const EntityType methodEntity = EntityType._('method');

  static const Iterable<EntityType> all = [classEntity, methodEntity];

  final String _value;

  const EntityType._(this._value);

  @override
  String toString() => _value;
}
