// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../analyzer.dart';
import '../util/flutter_utils.dart';

const _desc = r''; // TODO

const _details = r''; // TODO

class SortNamedParametersAlphabetically extends LintRule {
  SortNamedParametersAlphabetically()
      : super(
            name: 'sort_named_parameters_alphabetically',
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

    // TODO: check if sort_child_properties_last is active
    // TODO: check if sort_key_properties_first is active (sort_key_properties_first does not yet exist)
    // For now, assume key first and child last



    var nothingBeforeKey = arguments
        .takeWhile((argument) => !isKeyArg(argument))
        .toList()
        .where((element) =>
            element is NamedExpression &&
            element.expression is! FunctionExpression)
        .isEmpty;
    if (!nothingBeforeKey) {
      rule.reportLint(arguments.firstWhere(isKeyArg));
    }

    var onlyClosuresAfterChild = arguments.reversed
        .takeWhile((argument) => !isChildArg(argument))
        .toList()
        .reversed // What does second reversed do?
        .where((element) =>
            element is NamedExpression &&
            element.expression is! FunctionExpression)
        .isEmpty;
    if (!onlyClosuresAfterChild) {
      rule.reportLint(arguments.firstWhere(isChildArg));
    }

    var argumentsExceptKeyAndChild = arguments
        .where((element) => !isChildArg(element) && !isKeyArg(element));

    //TODO Alphabetize list without key + child/children
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
}
