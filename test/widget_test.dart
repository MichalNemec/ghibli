import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seznam_ghibli/main.dart';
import 'package:seznam_ghibli/providers/dio_provider.dart';
import 'package:seznam_ghibli/providers/storage_provider.dart';
import 'package:seznam_ghibli/storage/favorites_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/mocks.mocks.dart';

void main() {
  testWidgets('App renders films screen', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();
    final storage = FavoritesStorage(sharedPreferences);
    final mockClient = MockRestClient();
    final mockFilms = MockFilmsClient();
    when(mockClient.films).thenReturn(mockFilms);
    when(
      mockFilms.getFilms(limit: anyNamed('limit')),
    ).thenAnswer((_) async => []);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          favoritesStorageProvider.overrideWithValue(storage),
          restClientProvider.overrideWithValue(mockClient),
        ],
        child: const GhibliApp(),
      ),
    );

    await tester.pump();

    expect(find.byType(Scaffold), findsOneWidget);
  });
}
