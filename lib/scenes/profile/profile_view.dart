import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';

import 'profile_view_model.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({required this.viewModel, super.key});

  final ProfileViewModel viewModel;

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _name = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Preenche o campo quando o perfil chega.
    widget.viewModel.load().then((_) {
      if (mounted) _name.text = widget.viewModel.name;
    });
  }

  @override
  void dispose() {
    _name.dispose();
    widget.viewModel.dispose();
    super.dispose();
  }

  static const _themes = <ChipOption<ThemeMode>>[
    (value: ThemeMode.light, label: 'Claro'),
    (value: ThemeMode.dark, label: 'Escuro'),
    (value: ThemeMode.system, label: 'Sistema'),
  ];

  Future<void> _confirmLogout() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Sair da conta?',
      message: 'Você vai precisar entrar de novo.',
      confirmLabel: 'Sair',
    );
    if (confirmed) await widget.viewModel.logout();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;
    final theme = Theme.of(context);

    return AppScaffold(
      title: 'Perfil',
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          if (viewModel.isLoading) return const StateView.loading();
          if (viewModel.errorMessage != null) {
            return StateView.error(
              message: viewModel.errorMessage!,
              onRetry: viewModel.load,
            );
          }
          return ListView(
            children: [
              ProfileHeader(
                name: viewModel.name,
                email: viewModel.email,
                avatarUrl: viewModel.avatarUrl,
                caption: viewModel.memberSince,
              ),
              AppTextField(
                key: const Key('profile_name'),
                label: 'Nome',
                controller: _name,
                prefixIcon: Icons.person_outline,
                textCapitalization: TextCapitalization.words,
                errorText: viewModel.nameError,
                helperText: viewModel.savedMessage,
                onChanged: viewModel.onNameChanged,
                onSubmitted: (_) => viewModel.saveName(),
              ),
              const Gap.md(),
              AppButton(
                key: const Key('profile_save'),
                label: 'Salvar nome',
                isLoading: viewModel.isSaving,
                onPressed: viewModel.saveName,
              ),
              const SectionHeader(title: 'Aparência'),
              AppChoiceChips<ThemeMode>(
                options: _themes,
                selected: viewModel.themeMode,
                onSelected: viewModel.onThemeModeChanged,
              ),
              const Gap.xxl(),
              AppButton.secondary(
                key: const Key('profile_logout'),
                label: 'Sair da conta',
                icon: Icons.logout,
                isLoading: viewModel.isLoggingOut,
                onPressed: _confirmLogout,
              ),
              const Gap.sm(),
              Text(
                'Carteira Digital 1.0',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: context.semanticColors.muted,
                ),
              ),
              const Gap.xl(),
            ],
          );
        },
      ),
    );
  }
}
