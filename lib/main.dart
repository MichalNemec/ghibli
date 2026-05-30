// Entry point
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seznam_ghibli/providers/navigation_provider.dart';
import 'package:seznam_ghibli/providers/storage_provider.dart';
import 'package:seznam_ghibli/screens/shell.dart';
import 'package:seznam_ghibli/themes/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const GhibliApp(),
    ),
  );
}

class GhibliApp extends ConsumerWidget {
  const GhibliApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracker = ref.watch(routeTrackerProvider);

    return MaterialApp(
      title: 'Ghibli',
      debugShowCheckedModeBanner: false,
      theme: appDarkTheme,
      darkTheme: appDarkTheme,
      themeMode: ThemeMode.dark,
      navigatorObservers: [tracker],
      home: const MainShell(),
    );
  }
}
