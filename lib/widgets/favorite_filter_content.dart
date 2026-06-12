import 'package:cue/cue.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seznam_ghibli/providers/favorites_provider.dart';
import 'package:seznam_ghibli/widgets/modal_panel.dart';
import 'package:seznam_ghibli/widgets/star_range_slider.dart';

/// A reusable filter dialog for the favorites screen.
///
/// Contains a star-range slider and a "show unrated" toggle, wired to
/// [favoritesFilterProvider]. Designed to be placed inside the builder of
/// [CueModalTransition] as its content body.
class FavoriteFilterContent extends ConsumerWidget {
  /// [size] is the initial size of the trigger widget, used for the
  /// .sizedClip cue animation that expands the panel from the FAB.
  const FavoriteFilterContent({required this.size, super.key});

  /// Size of the trigger (FAB) used for the expand-from animation
  final Size size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final filterProvider = ref.watch(favoritesFilterProvider);
    final filter = ref.read(favoritesFilterProvider.notifier);

    return ModalPanel(
      child: Actor(
        acts: [
          .sizedClip(
            from: .size(size),
            to: const .width(280),
            alignment: .bottomRight,
          ),
          const .opacity(from: 0, to: 1),
          const .slideY(from: 0.4),
        ],
        child: Padding(
          padding: const .all(16),
          child: Column(
            mainAxisSize: .min,
            crossAxisAlignment: .start,
            children: [
              SizedBox(
                height: 48,
                child: Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    Text(
                      'Filter by rating',
                      style: theme.textTheme.titleMedium,
                    ),
                    IconButton(
                      key: const ValueKey('reset_filter'),
                      onPressed: filterProvider.isDefault ? null : filter.reset,
                      icon: Icon(
                        Icons.filter_list_off,
                        color: filterProvider.isDefault
                            ? theme.colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.3,
                              )
                            : theme.colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: StarRangeSlider(
                  key: const ValueKey('star_range_slider'),
                  min: filterProvider.minRating,
                  max: filterProvider.maxRating,
                  onChanged: (v) =>
                      filter.setRange(v.start.round(), v.end.round()),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Show unrated'),
                  const Spacer(),
                  Switch(
                    key: const ValueKey('show_unrated_switch'),
                    value: filterProvider.showUnrated,
                    onChanged: filter.setShowUnrated,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
