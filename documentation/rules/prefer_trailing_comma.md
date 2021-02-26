# Prefer trailing comma (prefer_trailing_comma)

## Description

Requires trailing commas in arguments, parameters, enum values and collections.

**Note**: Warns in cases when all items aren't on a single line. If the last item starts on the same line as opening bracket and ends on the same line as closing, the rule will not warn about this case.

```dart
function('some string', () {
  return;
});
```

### Example

Bad:

```dart
var foo = {
  bar: "baz",
  qux: "quux"
};

var arr = [
  1,
  2
];

foo({
  bar: "baz",
  qux: "quux"
});
```

Good:

```dart
var foo = {
  bar: "baz",
  qux: "quux",
};

var arr = [
  1,
  2,
];

foo({
  bar: "baz",
  qux: "quux",
});
```
