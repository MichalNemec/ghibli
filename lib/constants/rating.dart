import 'package:flutter/material.dart';

/// Minimum star rating value.
const minRating = 1;

/// Maximum star rating value.
const maxRating = 5;

/// Static color for rating
const Color ratingColor = Colors.amber;

/// Validates that [rating] is within [minRating]–[maxRating].
///
/// Throws [RangeError] if out of bounds. Returns the validated value.
int checkRating(int rating) {
  if (rating < minRating || rating > maxRating) {
    throw RangeError.range(rating, minRating, maxRating, 'rating');
  }
  return rating;
}
