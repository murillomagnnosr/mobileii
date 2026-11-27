import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';

/// One row of a [MenuPanel]: opens [page] when tapped.
class GalleryEntry {
  const GalleryEntry({
    required this.title,
    required this.icon,
    required this.page,
    this.subtitle,
  });

  final String title;
  final IconData icon;
  final Widget page;
  final String? subtitle;
}

/// Navigation list on a glass panel: tint squircle, title, chevron and
/// inset dividers.
///
/// Routes are pushed with the entry title as their name, so a flow can pop
/// back to a page with `ModalRoute.withName(title)`.
class MenuPanel extends StatelessWidget {
  const MenuPanel({required this.entries, super.key});

  final List<GalleryEntry> entries;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return AppPanel(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Column(
        children: [
          for (final (index, entry) in entries.indexed) ...[
            // 16 tile padding + 40 squircle + 16 gap.
            if (index > 0) const Divider(indent: 72),
            ListTile(
              leading: TintSquircle(icon: entry.icon),
              title: Text(entry.title),
              subtitle: entry.subtitle == null ? null : Text(entry.subtitle!),
              trailing: Icon(Icons.chevron_right_rounded, color: muted),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  settings: RouteSettings(name: entry.title),
                  builder: (_) => entry.page,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 40px squircle tinted with primary at `tintAlpha`, holding a 20px icon.
class TintSquircle extends StatelessWidget {
  const TintSquircle({required this.icon, super.key});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: primary.withValues(alpha: context.effects.tintAlpha),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SizedBox.square(
        dimension: 40,
        child: Icon(icon, size: 20, color: primary),
      ),
    );
  }
}
