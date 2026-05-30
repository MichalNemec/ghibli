// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'film_rating.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FilmRating _$FilmRatingFromJson(Map<String, dynamic> json) => FilmRating(
  isFavorite: json['isFavorite'] as bool? ?? false,
  rating: (json['rating'] as num?)?.toInt(),
);

Map<String, dynamic> _$FilmRatingToJson(FilmRating instance) =>
    <String, dynamic>{
      'isFavorite': instance.isFavorite,
      'rating': ?instance.rating,
    };
