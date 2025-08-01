import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:possystem/components/style/gradient_scroll_hint.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/helpers/breakpoint.dart';

class ResponsiveDialog extends StatelessWidget {
  final Widget title;
  final Widget content;
  final Widget? action;
  final Widget? floatingActionButton;
  final bool scrollable;
  final GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;

  const ResponsiveDialog({
    super.key,
    required this.title,
    required this.content,
    this.floatingActionButton,
    this.action,
    this.scrollable = true,
    this.scaffoldMessengerKey,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    // Lower threshold to use dialog mode for screens > 600px instead of > 840px
    final dialog = size.width > Breakpoint.compact.max;
    


    if (dialog) {
      // Calculate responsive width: 40-60% of screen width, min 400px, max 80% screen width
      final minWidth = 400.0;
      final maxWidthPercent = 0.8;
      final preferredWidthPercent = size.width > 1200 ? 0.4 : 0.6;
      
      final preferredWidth = size.width * preferredWidthPercent;
      final maxWidth = size.width * maxWidthPercent;
      final effectiveWidth = preferredWidth.clamp(minWidth, maxWidth);
      


      final dialog = Center(
        child: SizedBox(
          width: effectiveWidth,
          child: AlertDialog(
            title: title,
            contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            scrollable: scrollable,
            content: Stack(
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: 200, // Minimum height for better desktop experience
                  ),
                  child: content,
                ),
                const Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: kDialogBottomSpacing,
                  child: GradientScrollHint(
                    isDialog: true,
                    direction: Axis.vertical,
                  ),
                ),
              ],
            ),
            actions: action == null
                ? null
                : [
                    PopButton(
                      key: const Key('pop'),
                      title: MaterialLocalizations.of(context).cancelButtonLabel,
                    ),
                    action!,
                  ],
          ),
        ),
      );

      // Using _PropertyHolderWidget to allow [Scaffold]'s snackbar able to be
      // clicked but not blocking the dialog.
      // https://stackoverflow.com/a/56290622/12089368
      return ScaffoldMessenger(
        key: scaffoldMessengerKey,
        child: Stack(children: [
          _Transparent(child: dialog),
          _Transparent(
            foreground: true,
            child: Scaffold(
              primary: false,
              floatingActionButton: floatingActionButton,
              floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
              backgroundColor: Colors.transparent,
            ),
          ),
        ]),
      );
    }

    return Dialog.fullscreen(
      child: ScaffoldMessenger(
        key: scaffoldMessengerKey,
        child: Scaffold(
          primary: false,
          floatingActionButton: floatingActionButton,
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          appBar: AppBar(
            primary: false,
            title: title,
            leading: const CloseButton(key: Key('pop')),
            actions: action == null ? [] : [action!],
          ),
          body: scrollable ? SingleChildScrollView(child: content) : content,
        ),
      ),
    );
  }
}

class _Transparent extends SingleChildRenderObjectWidget {
  final bool foreground;

  const _Transparent({
    this.foreground = false,
    required super.child,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return foreground ? _Foreground() : RenderProxyBox();
  }

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {}
}

class _Foreground extends RenderProxyBox {
  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    super.hitTest(result, position: position);

    /// If greater than 10, it means not just tap on the empty space
    /// for example:
    /// - tap on FloatingActionButton has 18 targets
    /// - tap on Snackbar has 18 targets
    return result.path.length > 10;
  }
}
