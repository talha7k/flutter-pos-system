import 'package:flutter/material.dart';
import 'package:possystem/components/dialog/responsive_dialog.dart';
import 'package:possystem/components/style/pop_button.dart';

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    required this.title,
    this.content,
  });

  final String title;
  final Widget? content;

  static Future<bool> show(
    BuildContext context, {
    required String title,
    String? content,
    Widget? body,
  }) async {
    final result = await showDialog<bool?>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: title,
        content: body ?? (content == null ? null : Text(content)),
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final local = MaterialLocalizations.of(context);
    return ResponsiveDialog(
      title: Text(title),
      content: content ?? const SizedBox.shrink(),
      action: FilledButton(
        key: const Key('confirm_dialog.confirm'),
        onPressed: () => Navigator.of(context).pop(true),
        child: Text(local.okButtonLabel),
      ),
    );
  }
}
