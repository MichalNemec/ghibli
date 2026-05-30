import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seznam_ghibli/navigation.dart';

/// Provides the singleton [RouteTracker] used by the app's navigator
final routeTrackerProvider = Provider<RouteTracker>((ref) => RouteTracker());
