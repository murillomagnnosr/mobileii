import 'package:flutter/material.dart';

import '../theme/app_effects.dart';
import '../theme/app_semantic_colors.dart';
import '../tokens/app_durations.dart';
import '../tokens/app_motion.dart';
import '../tokens/app_spacing.dart';
import 'app_panel.dart';
import 'kind_style.dart';
import 'money_text.dart';

/// Kind of movement a [TransactionTile] represents. Lives in the design
/// system so the package stays independent from the domain models.
enum TransactionKind {
  /// Money coming into the wallet: down arrow, "+" amount.
  income,

  /// Money leaving the wallet: up arrow, "−" amount.
  expense,

  /// Transfer: swap arrows, neutral amount without sign.
  transfer,
}

/// One row of the transactions list.
///
/// Plain by default (rows inside one glass panel, Extrato). With [capsule]
/// the row floats on its own glass capsule (Home); callers space capsules
/// with `Gap.sm()`.
class TransactionTile extends StatelessWidget {
  /// Creates a row for one transaction.
  const TransactionTile({
    required this.kind,
    required this.title,
    required this.amount,
    super.key,
    this.subtitle,
    this.onTap,
    this.capsule = false,
    this.entranceIndex,
  });

  /// Picks the orb, arrow, amount color and sign through [kindStyleOf].
  final TransactionKind kind;

  /// Main line (description), ellipsized on one line.
  final String title;

  /// Already formatted, e.g. "R\$ 89,90".
  final String amount;

  /// Muted second line, e.g. category and date.
  final String? subtitle;

  /// Called when the row is tapped. Null makes it inert.
  final VoidCallback? onTap;

  /// Wraps the row in an [AppPanel] with the light-only tile shadow.
  final bool capsule;

  /// Position in a staggered list. When set, the row fades and slides in
  /// once per mount; later rows (capped at 5) arrive slightly later.
  final int? entranceIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = kindStyleOf(context, kind);

    Widget tile = ListTile(
      onTap: onTap,
      leading: KindOrb(kind: kind),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleSmall,
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: context.semanticColors.muted,
              ),
            ),
      trailing: Padding(
        padding: const EdgeInsets.only(left: AppSpacing.sm),
        child: MoneyText(amount, tone: style.tone, signed: true),
      ),
    );

    // AppPanel is a Material, so the ListTile ripple paints on the capsule.
    if (capsule) {
      tile = AppPanel(
        padding: EdgeInsets.zero,
        shadows: context.effects.tileShadow,
        child: tile,
      );
    }

    final index = entranceIndex;
    if (index != null) {
      tile = TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: AppMotion.of(context, AppDurations.listEntranceAt(index)),
        curve: AppCurves.standard,
        builder: (context, t, child) => Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, 8 * (1 - t)),
            child: child,
          ),
        ),
        child: tile,
      );
    }
    return tile;
  }
}
