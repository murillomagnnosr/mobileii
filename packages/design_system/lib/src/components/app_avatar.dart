import 'package:flutter/material.dart';

import '../theme/app_effects.dart';
import '../tokens/app_typography.dart';

/// Circular avatar inside the brand gradient ring. Shows the network image
/// when [imageUrl] is present and loads; otherwise the initials of [name].
///
/// The outer size is always [size]: the ring, the gap ring and the disc are
/// laid out inside it. At 64px or more the ring also gets the avatar glow.
class AppAvatar extends StatelessWidget {
  /// Creates an avatar for [name], 40px by default.
  const AppAvatar({
    required this.name,
    super.key,
    this.imageUrl,
    this.size = 40,
    this.heroTag,
  });

  /// Full name: source of the initials and of the semantics label.
  final String name;

  /// Network photo. Null, empty or failing to load shows the initials.
  final String? imageUrl;

  /// Outer side, ring included. 64 or more adds the avatar glow.
  final double size;

  /// When non-null, the whole avatar is wrapped in a [Hero] with this tag.
  /// Only one avatar per route may carry a given tag, so the gallery never
  /// passes one.
  final Object? heroTag;

  /// "Ana Ribeiro" -> "AR", "ana" -> "A", "" -> "?".
  static String initialsOf(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final e = context.effects;
    final large = size >= 64;
    final url = imageUrl;
    final fallback = Text(
      initialsOf(name),
      style: TextStyle(
        fontFamily: AppTypography.displayFamily,
        package: AppTypography.fontPackage,
        fontSize: size * 0.36,
        height: 1.0,
        letterSpacing: -0.5,
        fontWeight: FontWeight.w700,
        fontVariations: const [FontVariation('wght', 700)],
        color: scheme.onPrimaryContainer,
      ),
    );

    final Widget avatar = Semantics(
      image: true,
      label: 'Avatar de $name',
      child: SizedBox.square(
        dimension: size,
        // The ring is a decoration, never an Image (tests count Images).
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: e.ringGradient,
            boxShadow: large ? e.avatarGlow : null,
          ),
          child: Padding(
            padding: EdgeInsets.all(large ? 3 : 2),
            // 2px gap ring in the page color, between the ring and the disc.
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.scaffoldBackgroundColor,
              ),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: ClipOval(
                  child: ColoredBox(
                    color: scheme.primaryContainer,
                    child: url == null || url.isEmpty
                        ? Center(child: fallback)
                        : Image.network(
                            url,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Center(child: fallback),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final tag = heroTag;
    return tag == null ? avatar : Hero(tag: tag, child: avatar);
  }
}
