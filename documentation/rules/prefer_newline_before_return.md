# Prefer New Line Before Return (prefer_newline_before_return)

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
