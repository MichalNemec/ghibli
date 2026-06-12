import 'package:flutter/material.dart';
import 'package:seznam_ghibli/constants/rating.dart';

/// A dual-thumb slider for filtering by star rating range
class StarRangeSlider extends StatefulWidget {
  /// Creates a star range slider with [min] and [max] selection
  const StarRangeSlider({
    required this.min,
    required this.max,
    required this.onChanged,
    super.key,
  });

  /// The current minimum value (1–[kMaxRating])
  final int min;

  /// The current maximum value (1–[kMaxRating])
  final int max;

  /// Called when the range changes, with a [RangeValues] in star units
  final ValueChanged<RangeValues> onChanged;

  @override
  State<StarRangeSlider> createState() => _StarRangeSliderState();
}

class _StarRangeSliderState extends State<StarRangeSlider> {
  int? _activeThumb; // 0 for min, 1 for max
  late int _currentMin;
  late int _currentMax;

  @override
  void initState() {
    super.initState();
    _currentMin = widget.min;
    _currentMax = widget.max;
  }

  @override
  void didUpdateWidget(StarRangeSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_activeThumb == null) {
      _currentMin = widget.min;
      _currentMax = widget.max;
    }
  }

  void _handleTouch(double localX, double totalWidth) {
    final segmentWidth = totalWidth / kMaxRating;

    var targetValue = (localX / segmentWidth).floor() + 1;
    targetValue = targetValue.clamp(1, kMaxRating);

    if (_activeThumb == null) {
      final distToMin = (targetValue - _currentMin).abs();
      final distToMax = (targetValue - _currentMax).abs();

      if (distToMin == distToMax) {
        _activeThumb = targetValue < _currentMin ? 0 : 1;
      } else {
        _activeThumb = distToMin < distToMax ? 0 : 1;
      }
    }

    setState(() {
      if (_activeThumb == 0) {
        _currentMin = targetValue.clamp(1, _currentMax);
      } else {
        _currentMax = targetValue.clamp(_currentMin, kMaxRating);
      }
    });
  }

  void _dispatchChange() {
    widget.onChanged(
      RangeValues(_currentMin.toDouble(), _currentMax.toDouble()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const double widgetHeight = 64;
    const thumbRadius = 10;

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final segmentWidth = w / kMaxRating;

        final minCenterX = ((_currentMin - 1) * segmentWidth) + (segmentWidth / 2);
        final maxCenterX = ((_currentMax - 1) * segmentWidth) + (segmentWidth / 2);

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: (details) => _handleTouch(details.localPosition.dx, w),
          onHorizontalDragUpdate: (details) => _handleTouch(details.localPosition.dx, w),
          onHorizontalDragEnd: (_) {
            _activeThumb = null;
            _dispatchChange();
          },
          onTapDown: (details) {
            _handleTouch(details.localPosition.dx, w);
            _activeThumb = null;
            _dispatchChange();
          },
          child: SizedBox(
            height: widgetHeight,
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Inactive Track Background Pill
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: segmentWidth * 0.15,
                  ),
                  child: SizedBox(
                    height: 32,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),

                // Active Track Highlight Pill
                Positioned(
                  left: minCenterX - 20,
                  width: (maxCenterX - minCenterX) + 40,
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(
                        alpha: 0.7,
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),

                // Render Stars
                Row(
                  children: List.generate(kMaxRating, (index) {
                    final starValue = index + 1;
                    final isActive = starValue >= _currentMin && starValue <= _currentMax;

                    return Expanded(
                      child: Center(
                        child: Icon(
                          isActive ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: isActive
                              ? ratingColor
                              : theme.colorScheme.onSurfaceVariant.withValues(
                                  alpha: 0.6,
                                ),
                          size: 32,
                        ),
                      ),
                    );
                  }),
                ),

                // Min Thumb Handle Indicator
                Positioned(
                  left: minCenterX - thumbRadius,
                  bottom: 2,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    width: thumbRadius * 2,
                    height: thumbRadius * 2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.primary,
                      border: Border.all(
                        color: theme.colorScheme.surface,
                        width: 2,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 3,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 12,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),

                // Max Thumb Handle Indicator
                Positioned(
                  left: maxCenterX - thumbRadius,
                  bottom: 2,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    width: thumbRadius * 2,
                    height: thumbRadius * 2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.primary,
                      border: Border.all(
                        color: theme.colorScheme.surface,
                        width: 2,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 3,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.arrow_back_rounded,
                      size: 12,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
