// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../analyzer.dart';
import '../util/flutter_utils.dart';

const _desc =
    r'Sort arguments with key first, child last, and alphabetize the rest';

const _details = r'''
Sort arguments alphebetically with the exception of key and child. If present, 
key will be the first argument and child will be the last. This improves 
readabitiy, particuarly when using functions or classes that have very large 
amount of optional parameters.

**BAD:**
  inputDecorationTheme: InputDecorationTheme(
    contentPadding: EdgeInsets.all(10),
    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 30),
    fillColor: Colors.white,
    iconColor: const Colors.green,
    border: const OutlineInputBorder(
      borderSide:
          BorderSide(style: BorderStyle.none),
      borderRadius: BorderRadius.all(Radius.circular(13)),
    ),
    filled: true,
  ),
**GOOD:**
  inputDecorationTheme: InputDecorationTheme(
    border: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(13)),
      borderSide:
          BorderSide(style: BorderStyle.none),
    ),
    contentPadding: EdgeInsets.all(10),
    filled: true,
    fillColor: Colors.white,
    hintStyle: TextStyle(color: Colors.grey, fontSize: 30),
    iconColor: const Colors.green,
  ),

''';

class SortNamedParametersAlphabetically extends LintRule {
  SortNamedParametersAlphabetically()
      : super(
            name: 'sort_named_parameters',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    var visitor = _Visitor(this);
    registry.addInstanceCreationExpression(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor {
  final LintRule rule;

  _Visitor(this.rule);

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (!isWidgetType(node.staticType)) {
      return;
    }

    var arguments = node.argumentList.arguments;

    if (arguments.length < 2) {
      return;
    }

    // Check that if Key is present, it is the first named argument
    if (arguments.where(isKeyArg).length == 1) {
      if (!isKeyArg(
          arguments.firstWhere((element) => element is NamedExpression))) {
        rule.reportLint(arguments.firstWhere(isKeyArg));
      }
    }

    // Check that if Child/Children is present, it is the last argument
    if (arguments.where(isChildArg).length == 1) {
      if (!isChildArg(arguments.last)) {
        rule.reportLint(arguments.firstWhere(isChildArg));
      }
    }

    // Select all arguments that should be alphabetized
    var namedArgumentsExceptKeyAndChild = arguments.where((element) =>
        element is NamedExpression &&
        !isChildArg(element) &&
        !isKeyArg(element));

    if (namedArgumentsExceptKeyAndChild.length > 1) {
      _checkAlphabetical(namedArgumentsExceptKeyAndChild, arguments);
    }
  }

  static bool isChildArg(Expression e) {
    if (e is NamedExpression) {
      var name = e.name.label.name;
      return (name == 'child' || name == 'children') &&
          isWidgetProperty(e.staticType);
    }
    return false;
  }

  static bool isKeyArg(Expression e) {
    if (e is NamedExpression) {
      var name = e.name.label.name;
      return name == 'key' && isWidgetProperty(e.staticType);
    }
    return false;
  }

  void _checkAlphabetical(lintedArgument, arguments) {
    void reportArgument(NamedExpression argument) {
      rule.reporter.reportErrorForNode(
          LintCode(rule.name,
              'Sort non-key, non-child, named arguments alphabetically'),
          argument);
    }

    NamedExpression? previousArgument;
    for (NamedExpression argument in arguments) {
      String? previousName = previousArgument?.name.label.name;
      String name = argument.name.label.name;
      if (previousName != null && previousName.compareTo(name) > 0) {
        reportArgument(argument);
      }
    }
  }
}
