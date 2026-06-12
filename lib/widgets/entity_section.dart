import 'package:cue/cue.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seznam_ghibli/core/failure.dart';
import 'package:seznam_ghibli/widgets/failure_widget.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// A section that displays a list of related entities (people, species, etc.)
/// with loading, data, and error states.
class EntitySection<T> extends StatelessWidget {
  /// Creates an entity section with the given configuration
  const EntitySection({
    required this.title,
    required this.icon,
    required this.urls,
    required this.state,
    required this.nameOf,
    required this.urlOf,
    required this.onTap,
    this.match,
    this.onRetry,
    super.key,
  });

  /// Section header text
  final String title;

  /// Icon used for each entity tile
  final IconData icon;

  /// The list of entity URLs to look up within the loaded data
  final List<String>? urls;

  /// The current load state of the entity list
  final AsyncValue<List<T>> state;

  /// Extracts the display name from an entity
  final String? Function(T) nameOf;

  /// Extracts the URL from an entity for matching
  final String Function(T) urlOf;

  /// Called when an entity tile is tapped
  final void Function(T) onTap;

  /// Optional custom matcher to determine which entities to show.
  ///
  /// When null, entities are matched by URL against [urls].
  final bool Function(T)? match;

  /// Called when the user taps the retry button on an error
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    if (urls == null || urls!.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title),
        const SizedBox(height: 8),
        state.when(
          data: (data) {
            final matched = data.where((item) {
              if (match != null) return match!(item);
              return urls!.any((u) => u == urlOf(item));
            }).toList();
            final matchedKeys = matched.map(urlOf).toList();

            if (matched.isEmpty) {
              return const Text('None');
            }

            return _BuildData<T>(
              keys: matchedKeys,
              icon: icon,
              nameOf: nameOf,
              onTap: onTap,
              matched: matched,
            );
          },
          loading: () => const EntitySkeleton(),
          error: (error, _) => FailureWidget(
            failure: error as Failure,
            compact: true,
            onRetry: onRetry,
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _BuildData<T> extends StatelessWidget {
  const _BuildData({
    required this.keys,
    required this.icon,
    required this.nameOf,
    required this.onTap,
    required this.matched,
  });

  final List<String> keys;
  final IconData icon;
  final String? Function(T) nameOf;
  final void Function(T) onTap;
  final List<T> matched;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
        itemCount: matched.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final m = matched[index];
          return Cue.onScrollVisible(
            key: ValueKey('es_${keys[index]}'),
            acts: const [
              .scale(from: 0.75),
              .fadeIn(),
            ],
            child: EntityTile(
              icon: icon,
              name: nameOf(m) ?? '?',
              onTap: () => onTap(m),
            ),
          );
        },
      ),
    );
  }
}

/// A tappable card displaying an entity icon and name
class EntityTile extends StatelessWidget {
  /// Creates an entity tile with the given [icon], [name], and [onTap]
  const EntityTile({
    required this.icon,
    required this.name,
    required this.onTap,
    super.key,
  });

  /// The icon representing the entity type
  final IconData icon;

  /// The display name of the entity
  final String name;

  /// Called when the tile is tapped
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 100,
              maxWidth: 160,
            ),
            child: SizedBox(
              height: 100,
              child: Column(
                spacing: 12,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 48, color: theme.colorScheme.primary),
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A skeleton placeholder shown while entities are loading
class EntitySkeleton extends StatelessWidget {
  /// Creates a loading placeholder with dummy content
  const EntitySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Skeletonizer(
      child: Row(
        spacing: 8,
        children: List.generate(
          2,
          (_) => Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Column(
                spacing: 12,
                children: [
                  Icon(
                    Icons.person,
                    size: 32,
                    color: theme.colorScheme.primary,
                  ),
                  const Text('Entity name'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// An uppercased section heading
class SectionHeader extends StatelessWidget {
  /// Creates a section header with the given [title]
  const SectionHeader({required this.title, super.key});

  /// The text to display (rendered uppercased)
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}
