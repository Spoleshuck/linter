import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// TODO(spoleshuck): add tests specific to alphabetizing

class W0 extends Widget {
  @override
  Widget Build(BuildContext context){
    return Scaffold(
      body: Center(
        child: Center(), // OK
      )
    )
}

class W1 extends Widget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Center(), // LINT
        key: 0,
      ),
    );
  }
}

class W2 extends Widget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        key: 0,
        child: Center(), // OK
      ),
    );
  }
}

class W3 extends Widget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        key: 0,
        child: Center(
          child: Column(
            key: 0,
            children: [], // OK
          ),
        ),
      ),
    );
  }
}

class W4 extends Widget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        key: 0,
        child: Center(
          child: Column(
            children: [], // LINT
            key: 0,
          ),
        ),
      ),
    );
  }
}

/// see: https://dart-review.googlesource.com/c/sdk/+/161624
nestedChildren() {
  Column(
    children: [ // LINT
      Column(
        children: [ // LINT
          Text('a'),
        ],
        crossAxisAlignment: CrossAxisAlignment.center,
      ),
      Text('b'),
      Text('c'),
      Text('d'),
    ],
    crossAxisAlignment: CrossAxisAlignment.center,
  );
}

class WithClosure extends Widget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RawMaterialButton(
        key: Key(''),
        child: Center( // LINT
          child: Column(
            key: 0,
            children: [],
          ),
        ),
        onPressed: () {
          // some code
        },
      ),
    );
  }
}
