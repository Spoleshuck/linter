// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../analyzer.dart';

const _desc = r'Avoid relative imports for files in `lib/`.';

const _details = r'''*DO* avoid relative imports for files in `lib/`.

When mixing relative and absolute imports it's possible to create confusion
where the same member gets imported in two different ways.  An easy way to avoid
that is to ensure you have no relative imports that include `lib/` in their
paths.

**GOOD:**

```dart
import 'package:foo/bar.dart';

import 'baz.dart';

...
```

**BAD:**

```dart
import 'package:foo/bar.dart';

import '../lib/baz.dart';

...
```

''';

class AvoidRelativeLibImports extends LintRule {
  AvoidRelativeLibImports()
      : super(
            name: 'avoid_relative_lib_imports',
            description: _desc,
            details: _details,
            group: Group.errors);

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    var visitor = _Visitor(this);
    registry.addImportDirective(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final LintRule rule;

  _Visitor(this.rule);

  bool isRelativeLibImport(ImportDirective node) {
    // This check is too narrow.  Really we should be checking against the
    // resolved URI and not it's literal string content.
    // See: https://github.com/dart-lang/linter/issues/2419
    var uriContent = node.uriContent;
    if (uriContent != null) {
      var uri = Uri.tryParse(uriContent);
      if (uri != null && uri.scheme.isEmpty) {
        return uri.path.contains('/lib/');
      }
    }
    return false;
  }

  @override
  void visitImportDirective(ImportDirective node) {
    if (isRelativeLibImport(node)) {
      rule.reportLint(node.uri);
    }
  }
}
