import 'package:flutter/material.dart';

import '../../theme/ds_theme.dart';
import '../../tokens/ds_typography.dart';

/// Avatar redondo: foto da rede se houver, senão as iniciais do nome.
class DsAvatar extends StatelessWidget {
  final String name;
  final double size;
  final String? imageUrl;

  /// Mesma tag em duas telas faz o avatar "voar" entre elas.
  final Object? heroTag;

  const DsAvatar({super.key, required this.name, this.size = 44, this.imageUrl, this.heroTag});

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.ds;
    final fallback = Center(
      child: Text(_initials, style: DsTypography.label.copyWith(color: c.accent, fontSize: size * 0.36)),
    );
    final avatar = Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: c.accentSoft, shape: BoxShape.circle),
      child: imageUrl == null || imageUrl!.isEmpty
          ? fallback
          : Image.network(imageUrl!, fit: BoxFit.cover, errorBuilder: (context, error, stack) => fallback),
    );
    return heroTag == null ? avatar : Hero(tag: heroTag!, child: avatar);
  }
}
