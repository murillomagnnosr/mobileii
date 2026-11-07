import 'package:flutter/material.dart';

import '../theme/app_semantic_colors.dart';
import '../tokens/app_spacing.dart';
import 'app_avatar.dart';
import 'gap.dart';

/// Avatar, name and e-mail centered at the top of the profile screen, with
/// an optional caption pill underneath.
class ProfileHeader extends StatelessWidget {
  /// Creates the header for [name] and [email].
  const ProfileHeader({
    required this.name,
    required this.email,
    super.key,
    this.avatarUrl,
    this.caption,
    this.avatarHeroTag,
  });

  /// Full name: title line and avatar initials.
  final String name;

  /// Muted line under the name.
  final String email;

  /// Photo of the 96px [AppAvatar] (with glow); initials when null or
  /// broken.
  final String? avatarUrl;

  /// Short line in a pill, e.g. "Cliente desde março de 2024".
  final String? caption;

  /// Forwarded to [AppAvatar.heroTag]. Only the app's Perfil passes one.
  final Object? avatarHeroTag;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = context.semanticColors.muted;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        children: [
          AppAvatar(
            name: name,
            imageUrl: avatarUrl,
            size: 96,
            heroTag: avatarHeroTag,
          ),
          const Gap(AppSpacing.lg),
          Text(
            name,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge,
          ),
          const Gap(AppSpacing.xxs),
          Text(
            email,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: muted),
          ),
          if (caption != null) ...[
            const Gap(AppSpacing.md),
            DecoratedBox(
              decoration: ShapeDecoration(
                color: scheme.primaryContainer,
                shape: const StadiumBorder(),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 6,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      size: 14,
                      color: scheme.primary,
                    ),
                    const Gap(6),
                    // Flexible so a long caption wraps instead of overflowing.
                    Flexible(
                      child: Text(
                        caption!,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
