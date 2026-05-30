import 'package:json_annotation/json_annotation.dart';
import 'package:seznam_ghibli/constants/rating.dart';

part 'film_rating.g.dart';

@JsonSerializable(includeIfNull: false)
/// Tracks the user's favorite status and star rating for a single film.
class FilmRating {
  ///
  const FilmRating({
    this.isFavorite = false,
    this.rating,
  });

  ///
  factory FilmRating.fromJson(Map<String, Object?> json) => _$FilmRatingFromJson(json);

  ///
  Map<String, Object?> toJson() => _$FilmRatingToJson(this);

  /// Whether the user has marked this film as a favorite.
  final bool isFavorite;

  /// The user's star rating (1–[maxRating]), or null if unrated
  final int? rating;

  /// Returns a copy with the given fields replaced.
  FilmRating copyWith({bool? isFavorite, int? rating}) {
    return FilmRating(
      isFavorite: isFavorite ?? this.isFavorite,
      rating: rating ?? this.rating,
    );
  }

  /// Returns a copy with the rating removed, keeping the favorite status.
  FilmRating clearRating() {
    return FilmRating(
      isFavorite: isFavorite,
    );
  }
}
