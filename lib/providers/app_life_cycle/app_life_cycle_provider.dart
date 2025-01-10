import 'dart:async';

import 'package:flutter/material.dart';

class AppLifecycleProvider {
  late ValueNotifier<AppLifecycleState> _state;

  AppLifecycleProvider() {
    _state = ValueNotifier<AppLifecycleState>(AppLifecycleState.resumed);
  }

  set state(AppLifecycleState newState) {
    if (newState != _state.value) {
      print('AppLifecycleState: $newState');
      _state.value = newState;
    }
  }

  AppLifecycleState get state => _state.value;

  Future waitUntilState(AppLifecycleState state) async {
    if (_state == state) return;

    Completer completer = Completer();

    listener() {
      if (_state.value == state) {
        completer.complete();
        _state.removeListener(listener);
      }
    }

    _state.addListener(listener);

    return completer.future;
  }

  dispose() {
    _state.dispose();
  }
}
