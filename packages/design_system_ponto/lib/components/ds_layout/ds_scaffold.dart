import 'package:flutter/material.dart';

import '../../theme/ds_theme.dart';
import '../../tokens/ds_spacing.dart';
import '../../tokens/ds_typography.dart';
import 'ds_logo_mark.dart';

/// Tela padrão: barra superior, margem lateral de [DsSpacing.screenGutter] e área segura.
class DsScaffold extends StatelessWidget {
  final String? title;
  final List<Widget>? actions;
  final Widget body;
  final Widget? floatingActionButton;

  /// Aplica a margem lateral; desligue quando a lista cuida do próprio recuo.
  final bool padded;
  final bool showAppBar;

  /// Mostra a marca antes do título.
  final bool brand;

  const DsScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.floatingActionButton,
    this.padded = true,
    this.showAppBar = true,
    this.brand = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.ds;
    final content = padded
        ? Padding(padding: const EdgeInsets.symmetric(horizontal: DsSpacing.screenGutter), child: body)
        : body;

    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              titleSpacing: DsSpacing.screenGutter,
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (brand) ...[const DsLogoMark(size: 28), const SizedBox(width: DsSpacing.xs)],
                  if (title != null) Text(title!, style: DsTypography.title.copyWith(color: c.textPrimary)),
                ],
              ),
              actions: actions,
            )
          : null,
      floatingActionButton: floatingActionButton,
      body: SafeArea(top: !showAppBar, bottom: false, child: content),
    );
  }
}
