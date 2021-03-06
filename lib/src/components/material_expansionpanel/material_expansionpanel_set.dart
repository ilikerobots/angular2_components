// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular2/angular2.dart';

import '../../model/action/async_action.dart';
import '../../utils/disposer/disposer.dart';

import 'material_expansionpanel.dart';

/// A directive which will turn a set of expansion panels into an accordian
/// widget. Thus only allowing one panel to be open at a time.
@Directive(selector: 'material-expansionpanel-set')
class MaterialExpansionPanelSet implements OnDestroy {
  final _panelDisposer = new Disposer.multi();
  final _tearDownDisposer = new Disposer.oneShot();
  MaterialExpansionPanel _openPanel;
  QueryList<MaterialExpansionPanel> _panels;

  MaterialExpansionPanelSet(
      @ContentChildren(MaterialExpansionPanel) this._panels) {
    _tearDownDisposer.addStreamSubscription(
        _panels.changes.listen((_) => _onPanelsChange()));
    _onPanelsChange();
  }

  ngOnDestroy() {
    _panelDisposer.dispose();
    _tearDownDisposer.dispose();
  }

  _onPanelsChange() {
    _panelDisposer.dispose();
    _openPanel = null;
    _panels.forEach((panel) {
      if (panel.isExpanded) {
        if (_openPanel != null) {
          throw new StateError("Should only have one panel open at a time");
        }
        _openPanel = panel;
      }
      _panelDisposer.addDisposable(
          panel.open.listen((event) => _onPanelOpen(panel, event)));
      _panelDisposer.addDisposable(
          panel.close.listen((event) => _onPanelClose(panel, event)));
      _panelDisposer.addDisposable(
          panel.cancel.listen((event) => _onPanelClose(panel, event)));
    });
  }

  _onPanelOpen(MaterialExpansionPanel panel, AsyncAction<bool> event) {
    if (_openPanel != null) {
      if (_openPanel.activeSaveCancelAction) {
        // Do not open the new panel, when the currently opened panel has an
        // in-progress action.
        event.cancel();
        return;
      }

      event.cancelIf(_openPanel.collapse(byUserAction: false).then((success) {
        if (success) {
          _setOpenPanel(panel);
        }
        return !success;
      }));
    } else {
      _setOpenPanel(panel);
    }
  }

  _onPanelClose(MaterialExpansionPanel panel, AsyncAction<bool> e) {
    e.onDone.then((success) {
      if (success && _openPanel == panel) {
        _setOpenPanel(null);
      }
    });
  }

  _setOpenPanel(MaterialExpansionPanel panel) {
    _panels.forEach((p) {
      if (p != panel) p.anotherExpanded = (panel != null);
    });
    _openPanel = panel;
  }
}
