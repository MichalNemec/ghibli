import 'package:mockito/annotations.dart';
import 'package:seznam_ghibli/api/export.dart';
import 'package:seznam_ghibli/storage/favorites_storage.dart';

@GenerateNiceMocks([
  MockSpec<RestClient>(),
  MockSpec<FavoritesStorage>(),
  MockSpec<FilmsClient>(),
  MockSpec<PeopleClient>(),
])
void main() {}
