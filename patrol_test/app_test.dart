// Patrol test is test mode
// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patrol/patrol.dart';
import 'package:seznam_ghibli/api/export.dart';
import 'package:seznam_ghibli/main.dart';
import 'package:seznam_ghibli/providers/films_provider.dart';
import 'package:seznam_ghibli/providers/locations_provider.dart';
import 'package:seznam_ghibli/providers/people_provider.dart';
import 'package:seznam_ghibli/providers/species_provider.dart';
import 'package:seznam_ghibli/providers/storage_provider.dart';
import 'package:seznam_ghibli/providers/vehicles_provider.dart';
import 'package:seznam_ghibli/storage/favorites_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  patrolTest(
    'app launches and shows film list',
    ($) async {
      SharedPreferences.setMockInitialValues({});
      final sharedPreferences = await SharedPreferences.getInstance();
      await sharedPreferences.clear();
      final storage = FavoritesStorage(sharedPreferences);

      await $.pumpWidgetAndSettle(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(sharedPreferences),
            favoritesStorageProvider.overrideWithValue(storage),
          ],
          child: const GhibliApp(),
        ),
      );

      await $(Scaffold).waitUntilVisible();
    },
  );

  patrolTest(
    '15-step end-to-end flow: browse, favorite, rate, filter, search',
    ($) async {
      SharedPreferences.setMockInitialValues({});
      final sharedPreferences = await SharedPreferences.getInstance();
      await sharedPreferences.clear();
      final storage = FavoritesStorage(sharedPreferences);

      const film1 = Films(
        id: 'film1',
        title: 'My Neighbor Totoro',
        originalTitle: 'となりのトトロ',
        originalTitleRomanised: 'Tonari no Totoro',
        description: 'Two sisters move to the country.',
        director: 'Hayao Miyazaki',
        producer: 'Hayao Miyazaki',
        releaseDate: '1988',
        runningTime: '86',
        rtScore: '93',
        people: ['https://ghibliapi.vercel.app/people/person1'],
        species: [],
        locations: [],
        vehicles: [],
        url: 'https://ghibliapi.vercel.app/films/film1',
      );
      const film2 = Films(
        id: 'film2',
        title: 'Spirited Away',
        originalTitle: '千と千尋の神隠し',
        originalTitleRomanised: 'Sen to Chihiro no Kamikakushi',
        description: 'A young girl wanders into a bathhouse for spirits.',
        director: 'Hayao Miyazaki',
        producer: 'Toshio Suzuki',
        releaseDate: '2001',
        runningTime: '125',
        rtScore: '96',
        people: [],
        species: [],
        locations: [],
        vehicles: [],
        url: 'https://ghibliapi.vercel.app/films/film2',
      );
      const film3 = Films(
        id: 'film3',
        title: 'Castle in the Sky',
        originalTitle: '天空の城ラピュタ',
        originalTitleRomanised: 'Tenkū no Shiro Rapyuta',
        description: 'A young boy and girl search for a floating castle.',
        director: 'Hayao Miyazaki',
        producer: 'Isao Takahata',
        releaseDate: '1986',
        runningTime: '124',
        rtScore: '95',
        people: [],
        species: [],
        locations: [],
        vehicles: [],
        url: 'https://ghibliapi.vercel.app/films/film3',
      );

      const person1 = People(
        id: 'person1',
        name: 'Satsuki',
        gender: 'Female',
        age: '11',
        eyeColor: 'Brown',
        hairColor: 'Brown',
        films: ['https://ghibliapi.vercel.app/films/film1'],
        species: 'https://ghibliapi.vercel.app/species/human',
        url: 'https://ghibliapi.vercel.app/people/person1',
      );

      await $.pumpWidgetAndSettle(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(sharedPreferences),
            favoritesStorageProvider.overrideWithValue(storage),
            filmsProvider.overrideWith(
              () => FakeFilmsNotifier(const FilmsData([film1, film2, film3])),
            ),
            peopleProvider.overrideWith(
              () => FakePeopleNotifier(const PeopleData([person1])),
            ),
            speciesProvider.overrideWith(
              () => FakeSpeciesNotifier(const SpeciesData([])),
            ),
            locationsProvider.overrideWith(
              () => FakeLocationsNotifier(const LocationsData([])),
            ),
            vehiclesProvider.overrideWith(
              () => FakeVehiclesNotifier(const VehiclesData([])),
            ),
          ],
          child: const GhibliApp(),
        ),
      );

      // Step 1 - wait for shell to load (favorites FAB is visible)
      await $(#shell_favorites_fab).waitUntilVisible();

      // Step 2 - wait for film cards to show up
      await $(#fs_film1).waitUntilVisible();
      await $(#fs_film2).waitUntilVisible();
      await $(#fs_film3).waitUntilVisible();

      // Step 3 - tap first film card
      await $(#fs_film1).tap();

      // Step 4 - wait for entity sections (People section header)
      await $('PEOPLE').waitUntilVisible();

      // Step 5 - tap first person (Satsuki)
      await $('Satsuki').tap();

      // Step 6 - navigate back (people detail -> film detail)
      await $(BackButton).tap();
      await $.pumpAndSettle();

      // Step 7 - navigate back (film detail -> film list)
      await $(BackButton).tap();
      await $.pumpAndSettle();

      // Step 8 - tap favorite on first film card
      await $(#fav_film1).tap();

      // Step 9 - rate second film card (tap star 3)
      await $(#star_film2_3).tap();

      // Step 10 - favorite + rate third film card
      await $(#fav_film3).tap();
      await $(#star_film3_4).tap();

      // Step 11 - navigate to favorites screen
      await $(#shell_favorites_fab).tap();

      // Step 12 - open filter, interact, close
      await $(#filter_fab).tap();
      await $(#star_range_slider).waitUntilVisible();
      await $(#show_unrated_switch).tap();
      await $(#reset_filter).tap();
      // dismiss the filter modal by tapping outside (top-left)
      await $.tester.tapAt(Offset.zero);

      // Step 13 - navigate back from favorites to film list
      await $(BackButton).tap();
      await $.pumpAndSettle();

      // Step 14 - type search query (debounced 300ms)
      await $(#search_field).enterText('Totoro');
      await $.pump(const Duration(milliseconds: 400));

      // Step 15 - tap first search result
      await $('My Neighbor Totoro').tap();
    },
  );
}
