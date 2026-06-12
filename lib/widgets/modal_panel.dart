import 'package:cue/cue.dart';
import 'package:flutter/material.dart';

/// A reusable floating panel wrapper with rounded-rect material surface
/// and cue animation offset. Designed as the outer shell for modal popups
/// triggered by [CueModalTransition].
class ModalPanel extends StatelessWidget {
  /// Creates a panel that wraps [child] with a themed material surface.
  const ModalPanel({required this.child, super.key});

  /// The content to render inside the panel
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Actor(
      acts: const [.translate(to: Offset(-28, -28))],
      child: Material(
        clipBehavior: .hardEdge,
        borderRadius: .circular(32),
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        child: child,
      ),
    );
  }
}
