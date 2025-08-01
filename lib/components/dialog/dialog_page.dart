import 'package:flutter/material.dart';
import 'package:possystem/components/dialog/responsive_dialog.dart';
import 'package:possystem/components/scaffold/item_modal.dart';

/// A dialog page with Material entrance and exit animations, modal barrier color,
/// and modal barrier behavior (dialog is dismissible with a tap on the barrier).
///
/// exported from https://croxx5f.hashnode.dev/adding-modal-routes-to-your-gorouter
class MaterialDialogPage<T> extends Page<T> {
  final Offset? anchorPoint;
  final Color? barrierColor;
  final bool barrierDismissible;
  final String? barrierLabel;
  final bool useSafeArea;
  final CapturedThemes? themes;
  final TraversalEdgeBehavior? traversalEdgeBehavior;

  /// only if constant child is allowed, otherwise use [builder]
  final Widget? child;

  /// if child is constant, use [child] instead
  final WidgetBuilder? builder;

  const MaterialDialogPage({
    this.child,
    this.builder,
    this.anchorPoint,
    this.barrierColor = Colors.black54,
    this.barrierDismissible = true,
    this.barrierLabel,
    this.useSafeArea = true,
    this.themes,
    this.traversalEdgeBehavior,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  }) : assert(child != null || builder != null);

  @override
  Route<T> createRoute(BuildContext context) => DialogRoute<T>(
        context: context,
        settings: this,
        builder: (context) {
          final widget = builder?.call(context) ?? child!;
          final size = MediaQuery.sizeOf(context);
          
          // Apply responsive sizing for desktop
          if (size.width > 768) {
            final dialogWidth = (size.width * 0.6).clamp(400.0, size.width * 0.8);
            
            return AlertDialog.adaptive(
              contentPadding: EdgeInsets.zero,
              content: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: 400.0,
                  maxWidth: dialogWidth,
                  minHeight: 200.0,
                ),
                child: SizedBox(
                  width: dialogWidth,
                  child: widget,
                ),
              ),
            );
          }
          
          // For mobile, return the widget as-is
          return widget;
        },
        anchorPoint: anchorPoint,
        barrierColor: barrierColor,
        barrierDismissible: barrierDismissible,
        barrierLabel: barrierLabel,
        useSafeArea: useSafeArea,
        themes: themes,
        traversalEdgeBehavior: traversalEdgeBehavior,
      );
}
