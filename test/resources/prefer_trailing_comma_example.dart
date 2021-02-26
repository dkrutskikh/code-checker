// ignore_for_file: prefer_expression_function_bodies, prefer_trailing_comma

void firstFunction(
  String firstArgument,
  String secondArgument,
  String thirdArgument,
) {
  return;
}

void firstFunctionTrailing(
    String firstArgument, String secondArgument, String thirdArgument) {
  return;
}

void secondFunction(String arg1) {
  firstFunction(
    'some string',
    'some other string',
    'and another string for length exceed',
  );
}

void secondFunctionTrailing() {
  firstFunction('some string', 'some other string',
      'and another string for length exceed');
}

void thirdFunction(String arg1, void Function() callback) {}

void thirdFunctionTrailing(String someLongVarName,
    void Function() someLongCallbackName, String arg3) {}

void forthFunction(void Function() callback) {}

class TestClass {
  void firstMethod(
    String firstArgument,
    String secondArgument,
    String thirdArgument,
  ) {
    return;
  }

  void secondMethod() {
    firstMethod(
      'some string',
      'some other string',
      'and another string for length exceed',
    );

    thirdFunction('', () {
      return;
    });

    forthFunction(() {
      return;
    });
  }

  void thirdMethod(
    String arg1,
  ) {
    firstMethod(
      arg1,
      '',
      '',
    );
    firstFunction(
      arg1,
      '',
      '',
    );
  }
}

class TestClassTrailing {
  void firstMethod(
      String firstArgument, String secondArgument, String thirdArgument) {
    return;
  }

  void secondMethod() {
    firstMethod('some string', 'some other string',
        'and another string for length exceed');

    thirdFunctionTrailing('some string', () {
      return;
    }, 'some other string');
  }
}

enum FirstEnum {
  firstItem,
  secondItem,
  thirdItem,
  forthItem,
  fifthItem,

  /// sixthItem
  sixthItem,
}

enum FirstEnumTrailing {
  firstItem,
  secondItem,
  thirdItem,
  forthItem,
  fifthItem,

  /// sixthItem
  sixthItem
}

enum SecondEnum {
  firstItem,
}

enum ThirdEnum { firstItem }

class FirstClass {
  final num firstField;
  final num secondField;
  final num thirdField;
  final num forthField;

  const FirstClass(
    this.firstField,
    this.secondField,
    this.thirdField,
    this.forthField,
  );
}

class FirstClassTrailing {
  final num firstField;
  final num secondField;
  final num thirdField;
  final num forthField;

  const FirstClassTrailing(
      this.firstField, this.secondField, this.thirdField, this.forthField);
}

const firstInstance = FirstClass(0, 0, 0, 0);
const firstInstanceTrailing = FirstClassTrailing(
    3.14159265359, 3.14159265359, 3.14159265359, 3.14159265359);

const secondInstance = FirstClass(
  0,
  0,
  0,
  0,
);

const firstArray = ['some string'];

const secondArray = [
  'some string',
  'some other string',
  'and another string for length exceed',
];
const secondArrayTrailing = [
  'some string',
  'some other string',
  'and another string for length exceed'
];

const thirdArray = [
  'some string',
];

const firstSet = {'some string'};

const secondSet = {
  'some string',
  'some other string',
  'and another string for length exceed',
};
const secondSetTrailing = {
  'some string',
  'some other string',
  'and another string for length exceed'
};

const thirdSet = {
  'some string',
};

const firstMap = {'some string': 'some string'};

const secondMap = {
  'some string': 'and another string for length exceed',
  'and another string for length exceed':
      'and another string for length exceed',
};
const secondMapTrailing = {
  'some string': 'and another string for length exceed',
  'and another string for length exceed': 'and another string for length exceed'
};

const thirdMap = {
  'some string': 'some string',
};
