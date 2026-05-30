import 'dart:async';

import 'package:flutter/material.dart';

/// Builds a route name for a people detail screen from its [url].
String peopleRoute(String url) => 'people/$url';

/// Builds a route name for a species detail screen from its [url].
String speciesRoute(String url) => 'species/$url';

/// Builds a route name for a location detail screen from its [url].
String locationsRoute(String url) => 'locations/$url';

/// Builds a route name for a vehicle detail screen from its [url].
String vehiclesRoute(String url) => 'vehicles/$url';

/// Builds a route name for a film detail screen from its [url].
String filmsRoute(String url) => 'films/$url';

/// Route name for the favorites screen.
const favoritesRoute = 'favorites';

/// Tracks active route names in the navigation stack.
///
/// Used by [pushOrPopTo] to detect whether a route already exists
/// before deciding to pop back or push a new one.
class RouteTracker extends NavigatorObserver {
  final _names = <String>{};

  /// Whether a route with [name] is currently in the stack.
  bool contains(String name) => _names.contains(name);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final name = route.settings.name;
    if (name != null) _names.add(name);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final name = route.settings.name;
    if (name != null) _names.remove(name);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final name = route.settings.name;
    if (name != null) _names.remove(name);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    final oldName = oldRoute?.settings.name;
    if (oldName != null) _names.remove(oldName);
    final newName = newRoute?.settings.name;
    if (newName != null) _names.add(newName);
  }
}

/// Pushes [page] or pops back to an existing route with the same name.
///
/// Uses the [RouteTracker] attached to the current navigator's observers
/// to check existence without prematurely popping the stack.
void pushOrPopTo<T>(BuildContext context, MaterialPageRoute<T> page) {
  final routeName = page.settings.name;
  final navigator = Navigator.of(context);
  final tracker = navigator.widget.observers
      .whereType<RouteTracker>()
      .firstOrNull;

  if (routeName != null && tracker?.contains(routeName) == true) {
    navigator.popUntil(
      (route) => route.settings.name == routeName,
    );
  } else {
    unawaited(navigator.push(page));
  }
}
