import 'package:flutter/material.dart';

import '../tokens/app_spacing.dart';

/// Fixed empty space on the spacing scale. Works inside both [Row] and
/// [Column] because it sets width and height alike.
class Gap extends StatelessWidget {
  /// Space of [size]; prefer the named steps, which follow [AppSpacing].
  const Gap(this.size, {super.key});

  /// [AppSpacing.xxs] (2).
  const Gap.xxs({super.key}) : size = AppSpacing.xxs;

  /// [AppSpacing.xs] (4).
  const Gap.xs({super.key}) : size = AppSpacing.xs;

  /// [AppSpacing.sm] (8).
  const Gap.sm({super.key}) : size = AppSpacing.sm;

  /// [AppSpacing.md] (12).
  const Gap.md({super.key}) : size = AppSpacing.md;

  /// [AppSpacing.lg] (16).
  const Gap.lg({super.key}) : size = AppSpacing.lg;

  /// [AppSpacing.xl] (24).
  const Gap.xl({super.key}) : size = AppSpacing.xl;

  /// [AppSpacing.xxl] (32).
  const Gap.xxl({super.key}) : size = AppSpacing.xxl;

  /// Width and height of the space, in logical pixels.
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(width: size, height: size);
}

/// Divider with vertical breathing room, for lists and forms.
///
/// The line takes its color from the theme's `DividerThemeData`
/// (`outlineVariant`): a decorative hairline, never a control boundary.
class EmptyDivider extends StatelessWidget {
  /// Creates a divider with [AppSpacing.sm] above and below.
  const EmptyDivider({super.key, this.indent = 0});

  /// Left inset, to align the line with tile content.
  final double indent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Divider(indent: indent),
    );
  }
}
