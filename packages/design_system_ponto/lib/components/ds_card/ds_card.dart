import 'package:flutter/material.dart';

import '../../theme/ds_theme.dart';
import '../../tokens/ds_spacing.dart';
import '../../tokens/ds_typography.dart';

/// Cartão de conteúdo com título opcional, ação de toque e destaque na borda.
class DsCard extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget? leading;
  final Widget child;
  final VoidCallback? onTap;
  final bool highlighted;
  final EdgeInsetsGeometry padding;

  const DsCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(DsSpacing.md),
    this.title,
    this.subtitle,
    this.leading,
    this.onTap,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.ds;
    final content = Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null || leading != null)
            Row(
              children: [
                if (leading != null) ...[leading!, const SizedBox(width: DsSpacing.sm)],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (title != null) Text(title!, style: DsTypography.subtitle.copyWith(color: c.textPrimary)),
                      if (subtitle != null)
                        Text(subtitle!, style: DsTypography.bodySmall.copyWith(color: c.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          if (title != null || leading != null) const SizedBox(height: DsSpacing.sm),
          child,
        ],
      ),
    );

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DsRadius.lg),
        side: BorderSide(color: highlighted ? c.accent : c.border, width: highlighted ? 1.5 : 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: onTap == null ? content : InkWell(onTap: onTap, child: content),
    );
  }
}
