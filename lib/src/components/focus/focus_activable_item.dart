// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular2/angular2.dart';

import './focus.dart';

/// This directive is used to [ViewChild] focusable element in your view.
///
/// Assign a [key] in order to filter items from a [QueryList].
@Directive(selector: '[focusActivableItem]', providers: const [
  const Provider(FocusableActivateItem,
      useExisting: FocusActivableItemDirective)
])
class FocusActivableItemDirective extends RootFocusable
    implements FocusableActivateItem {
  /// Key to assign to the focusable item.
  @Input('focusActivableItem')
  String key;

  FocusActivableItemDirective(ElementRef root) : super(root);
}

/// A focusable component with a matching [key].
abstract class FocusableActivateItem implements Focusable {
  String get key;
}
