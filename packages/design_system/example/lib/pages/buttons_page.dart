import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class ButtonsPage extends StatefulWidget {
  const ButtonsPage({super.key});

  @override
  State<ButtonsPage> createState() => _ButtonsPageState();
}

class _ButtonsPageState extends State<ButtonsPage> {
  bool _loading = false;

  Future<void> _simulate() async {
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppScaffold(
      title: 'Botões',
      actions: const [ThemeModeButton()],
      // Full-width viewport with the gutter inside the list, so the CTA glows
      // fade out past the pill ends instead of being clipped flat.
      padded: false,
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.screen,
          0,
          AppSpacing.screen,
          AppSpacing.xxl + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          // Gradient + glow. The glow reaches ~30px below a pill, so glowing
          // primaries sit 32 apart and read as separate neon pills.
          const SectionHeader(title: 'Primary'),
          AppButton(label: 'Entrar', onPressed: () {}),
          const Gap.xxl(),
          AppButton(
            label: 'Com ícone',
            icon: Icons.add_rounded,
            onPressed: () {},
          ),
          const Gap.xxl(),
          // Loading has no glow, so the next gap can stay small.
          AppButton(label: 'Salvando', isLoading: true, onPressed: () {}),
          const Gap.md(),
          AppButton(
            label: 'Toque para carregar',
            isLoading: _loading,
            onPressed: _simulate,
          ),
          const Gap.xxl(),
          // Solid surfaceVariant, no glow.
          const AppButton(label: 'Desabilitado', onPressed: null),
          const SectionHeader(title: 'Secondary'),
          AppButton.secondary(label: 'Carregar mais', onPressed: () {}),
          const Gap.md(),
          AppButton.secondary(
            label: 'Excluir lançamento',
            icon: Icons.delete_outline_rounded,
            destructive: true,
            onPressed: () {},
          ),
          const Gap.md(),
          const AppButton.secondary(label: 'Desabilitado', onPressed: null),
          const SectionHeader(title: 'Text'),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              AppButton.text(label: 'Esqueci a senha', onPressed: () {}),
              AppButton.text(
                label: 'Excluir',
                icon: Icons.delete_outline_rounded,
                onPressed: () {},
              ),
            ],
          ),
          const SectionHeader(title: 'AppFab'),
          Row(
            children: [
              AppFab(tooltip: 'Novo lançamento', onPressed: () {}),
              const Gap.lg(),
              Expanded(
                child: Text(
                  'Gradiente diagonal com fabGlow. Entra uma vez com escala '
                  '0,8 → 1 e encolhe de leve ao ser pressionado.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
