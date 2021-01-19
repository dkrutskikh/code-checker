/// Enum class for type of a type of entity
class EntityType {
  static const EntityType classEntity = EntityType._('Class');
  static const EntityType methodEntity = EntityType._('Method');

  final String _value;

  const EntityType._(this._value);

  @override
  String toString() => _value;
}
