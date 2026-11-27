import 'package:flutter/material.dart';

import '../../theme/ds_theme.dart';
import '../../tokens/ds_spacing.dart';
import '../../tokens/ds_typography.dart';
import 'ds_avatar.dart';

/// Topo do perfil: avatar grande, nome, e-mail e uma legenda ("Membro desde...").
class DsProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String? avatarUrl;
  final String? caption;
  final Object? avatarHeroTag;

  const DsProfileHeader({
    super.key,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.caption,
    this.avatarHeroTag,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.ds;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DsSpacing.md),
      child: Column(
        children: [
          DsAvatar(name: name, size: 88, imageUrl: avatarUrl, heroTag: avatarHeroTag),
          const SizedBox(height: DsSpacing.sm),
          Text(name, textAlign: TextAlign.center, style: DsTypography.headline.copyWith(color: c.textPrimary)),
          const SizedBox(height: 2),
          Text(email, style: DsTypography.body.copyWith(color: c.textSecondary)),
          if (caption != null) ...[
            const SizedBox(height: DsSpacing.xxs),
            Text(caption!, style: DsTypography.caption.copyWith(color: c.textSecondary)),
          ],
        ],
      ),
    );
  }
}
