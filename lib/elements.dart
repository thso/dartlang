// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library atom.elements;

import 'dart:async';
import 'dart:html';

import 'package:atom/node/process.dart';

import 'atom.dart' hide Point;
import 'atom_utils.dart';
import 'utils.dart';

/// Finds the first descendant element of this document with the given id.
Element queryId(String id) => querySelector('#${id}');

/// Finds the first descendant element of this document with the given id.
Element $(String id) => querySelector('#${id}');

CoreElement button({String text, String c, String a}) =>
    new CoreElement('button', text: text, classes: c, attributes: a);

CoreElement div({String text, String c, String a}) =>
    new CoreElement('div', text: text, classes: c, attributes: a);

CoreElement span({String text, String c, String a}) =>
    new CoreElement('span', text: text, classes: c, attributes: a);

CoreElement italic({String text, String c, String a}) =>
    new CoreElement('i', text: text, classes: c, attributes: a);

CoreElement em({String text, String c, String a}) =>
    new CoreElement('em', text: text, classes: c, attributes: a);

CoreElement img({String text, String c, String a}) =>
    new CoreElement('img', text: text, classes: c, attributes: a);

CoreElement ol({String text, String c, String a}) =>
    new CoreElement('ol', text: text, classes: c, attributes: a);

CoreElement ul({String text, String c, String a}) =>
    new CoreElement('ul', text: text, classes: c, attributes: a);

CoreElement li({String text, String c, String a}) =>
    new CoreElement('li', text: text, classes: c, attributes: a);

CoreElement para({String text, String c, String a}) =>
    new CoreElement('p', text: text, classes: c, attributes: a);

class CoreElement {
  final Element element;

  CoreElement.from(this.element);

  CoreElement(String tag, {String text, String classes, String attributes}) :
      element = new Element.tag(tag) {
    if (text != null) element.text = text;
    if (classes != null) element.classes.addAll(classes.split(' '));
    if (attributes != null) attributes.split(' ').forEach(attribute);
  }

  String get tag => element.tagName;

  String get id => attributes['id'];
  set id(String value) => setAttribute('id', value);

  String get src => attributes['src'];
  set src(String value) => setAttribute('src', value);

  bool hasAttribute(String name) => element.attributes.containsKey(name);

  void attribute(String name, [bool value]) {
    if (value == null) value = !element.attributes.containsKey(name);

    if (value) {
      element.setAttribute(name, '');
    } else {
      element.attributes.remove(name);
    }
  }

  void toggleAttribute(String name, [bool value]) => attribute(name, value);

  Map<String, String> get attributes => element.attributes;

  void setAttribute(String name, [String value = '']) =>
      element.setAttribute(name, value);

  String clearAttribute(String name) => element.attributes.remove(name);

  void icon(String iconName) =>
      element.classes.addAll(['icon', 'icon-${iconName}']);

  void clazz(String _class) {
    if (_class.contains(' ')) {
      throw new ArgumentError('spaces not allowed in class names');
    }
    element.classes.add(_class);
  }

  void toggleClass(String name, [bool value]) {
    element.classes.toggle(name, value);
  }

  String get text => element.text;

  set text(String value) {
    element.text = value;
  }

  // Atom classes.
  void block() => clazz('block');
  void inlineBlock() => clazz('inline-block');
  void inlineBlockTight() => clazz('inline-block-tight');

  /// Add the given child to this element's list of children. [child] must be
  /// either a `CoreElement` or an `Element`.
  dynamic add(dynamic child) {
    if (child is List) {
      return child.map((c) => add(c)).toList();
    } else if (child is CoreElement) {
      element.children.add(child.element);
    } else if (child is Element) {
      element.children.add(child);
    } else {
      throw new ArgumentError('argument type not supported');
    }
    return child;
  }

  void hidden([bool value]) => attribute('hidden', value);

  String get label => attributes['label'];
  set label(String value) => setAttribute('label', value);

  bool get disabled => hasAttribute('disabled');
  set disabled(bool value) => attribute('disabled', value);

  bool get enabled => !disabled;
  set enabled(bool value) => attribute('disabled', !value);

  // Layout types.
  void layout() => attribute('layout');
  void horizontal() => attribute('horizontal');
  void vertical() => attribute('vertical');

  void layoutHorizontal() {
    setAttribute('layout');
    setAttribute('horizontal');
  }

  void layoutVertical() {
    setAttribute('layout');
    setAttribute('vertical');
  }

  // Layout params.
  void fit() => attribute('fit');
  void flex([int flexAmount]) {
    attribute('flex', true);

    if (flexAmount != null) {
      if (flexAmount == 1) attribute('one', true);
      else if (flexAmount == 2) attribute('two', true);
      else if (flexAmount == 3) attribute('three', true);
      else if (flexAmount == 4) attribute('four', true);
      else if (flexAmount == 5) attribute('five', true);
    }
  }

  String get tooltip => element.title;

  set tooltip(String value) {
    element.title = value;
  }

  Stream<MouseEvent> get onClick => element.onClick.where((_) => !disabled);

  /// Subscribe to the [onClick] event stream with a no-arg handler.
  StreamSubscription<Event> click(void handle()) {
    return onClick.listen((e) {
      e.stopImmediatePropagation();
      handle();
    });
  }

  /// Subscribe to the [onDoubleClick] event stream with a no-arg handler.
  StreamSubscription<Event> dblclick(void handle()) {
    return element.onDoubleClick.listen((e) {
      e.stopImmediatePropagation();
      handle();
    });
  }

  void clear() => element.children.clear();

  void scrollIntoView({bool bottom: false}) {
    if (bottom) {
      element.scrollIntoView(ScrollAlignment.BOTTOM);
    } else {
      element.scrollIntoView();
    }
  }

  void setInnerHtml(String str) {
    element.setInnerHtml(str, treeSanitizer: new TrustedHtmlTreeSanitizer());
  }

  /// Listen for a user copy event (ctrl-c / cmd-c) and copy the selected DOM
  /// bits into the user's paste buffer.
  void listenForUserCopy() {
    element.onKeyDown.listen(_handleCopyKeyPress);
  }

  void _handleCopyKeyPress(KeyboardEvent event) {
    // ctrl-c or cmd-c
    if (event.keyCode != 67) return;

    if ((isMac && event.metaKey) || (!isMac && event.ctrlKey)) {
      event.preventDefault();
      document.execCommand('copy', false, null);
    }
  }

  void dispose() {
    if (element.parent == null) return;

    if (element.parent.children.contains(element)) {
      try {
        element.parent.children.remove(element);
      } catch (e) {
      }
    }
  }

  String toString() => element.toString();
}

class ProgressElement extends CoreElement {
  CoreElement _progress;

  ProgressElement() : super('div') {
    block();
    _progress = add(new CoreElement('progress')..inlineBlock());
  }

  set value(int val) => _progress.setAttribute('value', val.toString());
  set max(int val) => _progress.setAttribute('max', val.toString());
}

class CloseButton extends CoreElement {
  CloseButton() : super('div', classes: 'close-button');
}

class TitledModelDialog implements Disposable {
  Panel _panel;
  Disposable _cancelCommand;

  CoreElement title;
  CoreElement content;

  TitledModelDialog(String inTitle, {String classes}) {
    CoreElement closeButton;

    CoreElement root = div(c: classes)..add([
      div(c: 'modal-header')..layoutHorizontal()..add([
        title = div(text: inTitle, c: 'text-highlight')..flex(),
        closeButton = new CloseButton()
      ]),
      content = div()
    ]);

    closeButton.onClick.listen((e) {
      hide();
      e.preventDefault();
    });

    _panel = atom.workspace.addModalPanel(item: root.element);
    _cancelCommand = atom.commands.add('atom-workspace', 'core:cancel', (_) => hide());
  }

  void show() => _panel.show();

  void hide() => _panel.hide();

  void dispose() {
    _panel.invoke('destroy');
    _cancelCommand.dispose();
  }
}

class Strobe extends CoreElement {
  static Duration _halfDuration = new Duration(milliseconds: 100);
  static Duration _fullDuration = new Duration(milliseconds: 200);

  Timer _timer;

  Strobe({String text, String classes}) :
      super('span', text: text, classes: classes) {
    toggleClass('strobe');
  }

  void strobe() {
    if (_timer != null) return;

    toggleClass('strobe-flash', true);
    new Timer(_halfDuration, () => toggleClass('strobe-flash', false));
    _timer = new Timer(_fullDuration, () => _timer = null);
  }
}
