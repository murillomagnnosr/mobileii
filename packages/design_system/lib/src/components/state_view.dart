import 'package:flutter/material.dart';

import '../theme/app_effects.dart';
import '../theme/app_semantic_colors.dart';
import '../tokens/app_durations.dart';
import '../tokens/app_motion.dart';
import '../tokens/app_spacing.dart';
import 'app_button.dart';
import 'gap.dart';

enum _StateKind { loading, empty, error }

/// Full-area placeholder for the three non-content states of a screen.
///
/// ```dart
/// StateView.loading()
/// StateView.empty(message: 'Nenhum lançamento neste mês')
/// StateView.error(message: 'Sem conexão', onRetry: vm.load.execute)
/// ```
///
/// Fades and scales in (0.96 -> 1) once, on first build.
class StateView extends StatelessWidget {
  /// Spinner on a soft primary halo, with an optional [message].
  const StateView.loading({super.key, this.message})
    : _kind = _StateKind.loading,
      icon = null,
      actionLabel = null,
      onAction = null;

  /// Primary squircle with the lime spark dot (one of the two spark spots of
  /// the screen), [message] and an optional action button.
  const StateView.empty({
    required String this.message,
    super.key,
    this.icon = Icons.inbox_rounded,
    this.actionLabel,
    this.onAction,
  }) : _kind = _StateKind.empty;

  /// Expense-tinted squircle, [message] and a "Tentar novamente" button
  /// when [onRetry] is set.
  const StateView.error({
    required String this.message,
    super.key,
    VoidCallback? onRetry,
    this.icon = Icons.error_outline,
    this.actionLabel = 'Tentar novamente',
  }) : _kind = _StateKind.error,
       onAction = onRetry;

  final _StateKind _kind;

  /// Muted, centered text under the visual (at most 280 wide).
  final String? message;

  /// Glyph of the squircle. Unused while loading.
  final IconData? icon;

  /// Label of the secondary button, shown only together with [onAction].
  final String? actionLabel;

  /// Button callback; `onRetry` of [StateView.error].
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = context.semanticColors;

    final Widget visual = switch (_kind) {
      _StateKind.loading => const _LoadingHalo(),
      _StateKind.empty => _Squircle(
        icon: icon,
        color: theme.colorScheme.primary,
        fill: theme.colorScheme.primaryContainer,
        spark: true,
      ),
      _StateKind.error => _Squircle(
        icon: icon,
        color: semantic.expense,
        fill: semantic.expenseContainer,
      ),
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: AppMotion.of(context, AppDurations.normal),
          curve: AppCurves.standard,
          builder: (context, t, child) => Opacity(
            opacity: t,
            child: Transform.scale(scale: 0.96 + 0.04 * t, child: child),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              visual,
              if (message != null) ...[
                const Gap(AppSpacing.lg),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 280),
                  child: Text(
                    message!,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: semantic.muted,
                    ),
                  ),
                ),
              ],
              if (onAction != null && actionLabel != null) ...[
                const Gap(AppSpacing.xl),
                AppButton.secondary(
                  label: actionLabel!,
                  onPressed: onAction,
                  expanded: false,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Spinner on a soft primary halo. Exactly one [CircularProgressIndicator].
class _LoadingHalo extends StatelessWidget {
  const _LoadingHalo();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final e = context.effects;
    return SizedBox.square(
      dimension: 96,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: e.wash(
            scheme.primary.withValues(alpha: 0.22),
            center: Alignment.center,
            radius: 0.5,
          ),
        ),
        child: Center(
          child: SizedBox.square(
            dimension: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              strokeCap: StrokeCap.round,
              color: scheme.primary,
              // surfaceVariant.
              backgroundColor: scheme.surfaceContainerHighest,
            ),
          ),
        ),
      ),
    );
  }
}

/// 72px tinted squircle with the state glyph. [spark] adds the lime dot on
/// the top-right corner (empty state only; counts in the spark budget).
class _Squircle extends StatelessWidget {
  const _Squircle({
    required this.icon,
    required this.color,
    required this.fill,
    this.spark = false,
  });

  final IconData? icon;
  final Color color;
  final Color fill;
  final bool spark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: color.withValues(alpha: 0.35),
              width: 1.5,
            ),
          ),
          child: SizedBox.square(
            dimension: 72,
            child: Center(child: Icon(icon, size: 32, color: color)),
          ),
        ),
        if (spark)
          Positioned(
            top: -3,
            right: -3,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.effects.spark,
                border: Border.all(
                  color: theme.scaffoldBackgroundColor,
                  width: 2,
                ),
              ),
              child: const SizedBox.square(dimension: 14),
            ),
          ),
      ],
    );
  }
}
