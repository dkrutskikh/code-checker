# New Line Before Return

## Rule id

newline-before-return

## Description

Enforces blank line between statements and return in a block.

### Example

Bad:

```dart
  if ( ... ) {
    ...
    return ...;
  }
```

Good:

```dart
  if ( ... ) {
    return ...;
  }

  if ( ... ) {
    ...

    return ...;
  }
```