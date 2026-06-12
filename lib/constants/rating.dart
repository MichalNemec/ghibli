import 'package:flutter/material.dart';

/// Minimum star rating value.
const kMinRating = 1;

/// Maximum star rating value.
const kMaxRating = 5;

/// Static color for rating
const Color ratingColor = Colors.amber;

/// Validates that [rating] is within [kMinRating]–[kMaxRating].
///
/// Throws [RangeError] if out of bounds. Returns the validated value.
int checkRating(int rating) {
  if (rating < kMinRating || rating > kMaxRating) {
    throw RangeError.range(rating, kMinRating, kMaxRating, 'rating');
  }
  return rating;
}
