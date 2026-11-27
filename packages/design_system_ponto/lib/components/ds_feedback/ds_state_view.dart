import 'package:flutter/material.dart';

import '../../theme/ds_theme.dart';
import '../../tokens/ds_spacing.dart';
import '../../tokens/ds_typography.dart';
import '../ds_button/ds_button_factory.dart';

enum _Kind { loading, empty, error }

/// Estados sem conteúdo de uma tela: carregando, vazio e erro.
class DsStateView extends StatelessWidget {
  const DsStateView.loading({super.key, this.message})
      : _kind = _Kind.loading,
        icon = null,
        actionLabel = null,
        onAction = null;

  const DsStateView.empty({
    super.key,
    required String this.message,
    this.icon = Icons.inbox_rounded,
    this.actionLabel,
    this.onAction,
  }) : _kind = _Kind.empty;

  const DsStateView.error({
    super.key,
    required String this.message,
    VoidCallback? onRetry,
    this.icon = Icons.error_outline_rounded,
    this.actionLabel = 'Tentar novamente',
  })  : _kind = _Kind.error,
        onAction = onRetry;

  final _Kind _kind;
  final String? message;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = context.ds;
    final tone = _kind == _Kind.error ? c.danger : c.accent;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DsSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_kind == _Kind.loading)
              CircularProgressIndicator(color: c.accent)
            else
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(color: tone.withValues(alpha: 0.14), shape: BoxShape.circle),
                child: Icon(icon, size: 30, color: tone),
              ),
            if (message != null) ...[
              const SizedBox(height: DsSpacing.md),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 280),
                child: Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: DsTypography.body.copyWith(color: c.textSecondary),
                ),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: DsSpacing.md),
              DsButtonFactory.secondary(label: actionLabel!, onPressed: onAction, expanded: false),
            ],
          ],
        ),
      ),
    );
  }
}
