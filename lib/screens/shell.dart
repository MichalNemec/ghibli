import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seznam_ghibli/models/search_result.dart';
import 'package:seznam_ghibli/navigation.dart';
import 'package:seznam_ghibli/providers/search_provider.dart';
import 'package:seznam_ghibli/screens/favorites/favorites_screen.dart';
import 'package:seznam_ghibli/screens/films/films_screen.dart';

/// Root shell
class MainShell extends StatelessWidget {
  ///
  const MainShell({super.key});

  void _onFavoritesTap(BuildContext context) {
    pushOrPopTo(
      context,
      MaterialPageRoute<void>(
        settings: const RouteSettings(name: 'favorites'),
        builder: (_) => const FavoritesScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: const SafeArea(
        child: FilmsScreen(),
      ),
      floatingActionButtonLocation: .centerFloat,
      floatingActionButton: Padding(
        padding: const .symmetric(horizontal: 16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 400,
          ),
          child: Row(
            spacing: 16,
            mainAxisAlignment: .center,
            crossAxisAlignment: .end,
            children: [
              const Expanded(child: _Search()),
              FloatingActionButton(
                key: const ValueKey('shell_favorites_fab'),
                onPressed: () => _onFavoritesTap(context),
                elevation: .5,
                shape: const CircleBorder(),
                child: const Icon(
                  Icons.favorite_rounded,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Search extends ConsumerStatefulWidget {
  ///
  const _Search();

  @override
  ConsumerState<_Search> createState() => _SearchState();
}

class _SearchState extends ConsumerState<_Search> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onSearchChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.removeListener(_onSearchChanged);
    _focusNode.removeListener(_onFocusChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Timer? _debounceTimer;

  void _onSearchChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      ref.read(searchQueryProvider.notifier).state = _controller.text;
    });
  }

  void _onFocusChanged() {
    setState(() {});
  }

  void _onResultTap(BuildContext context, SearchResult result) {
    _focusNode.unfocus();
    _controller.clear();
    ref.read(searchQueryProvider.notifier).state = '';
    pushOrPopTo(context, result.route!.call());
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(searchResultsProvider);
    final query = ref.read(searchQueryProvider.notifier).state;

    return AnimatedSize(
      alignment: .bottomCenter,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: .circular(
            query.isNotEmpty && results.isNotEmpty ? 16 : 28,
          ),
          color: Theme.of(
            context,
          ).colorScheme.surfaceContainerHigh,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextFieldTapRegion(
          child: Column(
            mainAxisSize: .min,
            children: [
              if (query.isNotEmpty && results.isNotEmpty && _focusNode.hasFocus)
                ClipRRect(
                  borderRadius: const .only(
                    topLeft: .circular(16),
                    topRight: .circular(16),
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: 200,
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: const .only(top: 8),
                      itemCount: results.length,
                      itemBuilder: (_, index) => _BuildResultTile(
                        key: ValueKey(results[index].label),
                        result: results[index],
                        onTap: (result) => _onResultTap(context, result),
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const .symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                child: TextField(
                  key: const ValueKey('search_field'),
                  controller: _controller,
                  focusNode: _focusNode,
                  onTapOutside: (_) => _focusNode.unfocus(),
                  decoration: const InputDecoration(
                    hintText: 'Search films, people...',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BuildResultTile extends StatelessWidget {
  const _BuildResultTile({
    required this.result,
    required this.onTap,
    super.key,
  });
  final SearchResult result;
  final void Function(SearchResult result) onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        canRequestFocus: false,
        onTap: result.route == null ? null : () => onTap(result),
        child: Padding(
          padding: const .symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(
                result.icon,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  result.label,
                  overflow: .ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              if (result.favorited)
                const Padding(
                  padding: .only(right: 4),
                  child: Icon(
                    Icons.favorite,
                    size: 14,
                    color: Colors.redAccent,
                  ),
                ),
              Text(
                result.subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
