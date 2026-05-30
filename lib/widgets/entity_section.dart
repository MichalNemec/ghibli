import 'package:cue/cue.dart';
import 'package:flutter/material.dart';
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
  final EntityLoadState<List<T>> state;

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
        switch (state) {
          EntityLoadInitial() || EntityLoadLoading() => const EntitySkeleton(),
          EntityLoadData<List<T>>() => _buildData(
            context,
            state as EntityLoadData<List<T>>,
          ),
          EntityLoadError() => FailureWidget(
            failure: (state as EntityLoadError).failure,
            compact: true,
            onRetry: onRetry,
          ),
        },
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildData(BuildContext context, EntityLoadData<List<T>> dataState) {
    final items = dataState.data;
    final matched = items.where((item) {
      if (match != null) return match!(item);
      return urls!.any((u) => u == urlOf(item));
    }).toList();

    if (matched.isEmpty) {
      return const Text('None');
    }

    return SizedBox(
      height: 230,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(0, 16, 0, 80),
        itemCount: matched.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final m = matched[index];
          return Cue.onScrollVisible(
            key: ValueKey('es_${m.hashCode}'),
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

/// Base state for an entity load operation
sealed class EntityLoadState<T> {
  const EntityLoadState();
}

/// Entities have not been loaded yet
class EntityLoadInitial<T> extends EntityLoadState<T> {
  /// Creates an initial load state
  const EntityLoadInitial();
}

/// Entities are currently loading
class EntityLoadLoading<T> extends EntityLoadState<T> {
  /// Creates a loading state
  const EntityLoadLoading();
}

/// Entities have been loaded successfully
class EntityLoadData<T> extends EntityLoadState<T> {
  /// Creates a data state with the given [data]
  const EntityLoadData(this.data);

  /// The loaded entity list
  final T data;
}

/// An error occurred while loading entities
class EntityLoadError<T> extends EntityLoadState<T> {
  /// Creates an error state with the given [failure]
  const EntityLoadError(this.failure);

  /// Details about what went wrong
  final Failure failure;
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
